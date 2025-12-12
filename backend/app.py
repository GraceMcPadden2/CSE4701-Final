##FLASK BACKEND API, CONNECTS TO ORACLE DB
##React app queries this API for all database request

#import modules
import oracledb
from flask import Flask, jsonify, request
from flask_cors import CORS, cross_origin

app = Flask(__name__)

#allows for react app to access flask server
CORS(app, resources={r"/*": {"origins": "http://localhost:5176"}})

import oracledb

#DB Connection
def get_db_connection():
    try:
        dsn = oracledb.makedsn("localhost", 1521, service_name="FREE")
        conn = oracledb.connect(user="system", password="MyPassword123", dsn=dsn)
        return conn
    except oracledb.Error as e:
        print("DB connection failed:", e)
        return None

@app.route('/items', methods=['GET'])
@cross_origin()
def get_items():
    """
    Return all products with id, name, price, and description.
    """
    conn = get_db_connection()
    if conn is None:
        return jsonify([]), 500

    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT product_id, product_name, price, description
                FROM Product
            """)
            items = [
                {
                    "id": pid,
                    "name": name,
                    "price": float(price),
                    "description": desc
                }
                for pid, name, price, desc in cursor.fetchall()
            ]

        conn.close()
        return jsonify(items)

    except Exception as e:
        print("Error in /items:", e)
        return jsonify([]), 500


@app.route('/cart/<int:customer_id>', methods=['GET'])
@cross_origin()
def get_cart(customer_id):
    """
    Return cart items for a customer.
    Joins Cart_Item with Product(product_name, price, description).
    """
    try:
        conn = get_db_connection()
        if conn is None:
            return jsonify([])
        cursor = conn.cursor()
        cursor.execute("""
            SELECT
                ci.product_id, 
                p.product_name, 
                p.price, 
                p.description, 
                ci.quantity
            FROM Cart_Item ci
            JOIN Product p ON ci.product_id = p.product_id
            WHERE ci.customer_id = :customer_id
        """, {"customer_id": customer_id})
        rows = cursor.fetchall()
        cart_items = [
            {"id": row[0], "name": row[1], "price": float(row[2]), "description": row[3], "quantity": row[4]}
            for row in rows
        ]
        cursor.close()
        conn.close()
        return jsonify(cart_items)
    except Exception as e:
        print("Error in /cart:", e)
        return jsonify([])

@app.route('/cart', methods=['POST'])
@cross_origin()
def add_to_cart():
    """
    Add a product to the cart or update its quantity.
    """
    data = request.get_json()

    customer_id = data["customer_id"]
    product_id = data["product_id"]
    quantity = data["quantity"]

    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database unavailable"}), 500

    try:
        with conn.cursor() as cursor:
            # Check if item is already in cart
            cursor.execute("""
                SELECT quantity
                FROM Cart_Item
                WHERE customer_id = :customer_id
                  AND product_id = :product_id
            """, {"customer_id": customer_id, "product_id": product_id})

            existing = cursor.fetchone()

            # Update or insert
            if existing:
                new_quantity = existing[0] + quantity
                cursor.execute("""
                    UPDATE Cart_Item
                    SET quantity = :quantity
                    WHERE customer_id = :customer_id
                      AND product_id = :product_id
                """, {
                    "quantity": new_quantity,
                    "customer_id": customer_id,
                    "product_id": product_id
                })
            else:
                cursor.execute("""
                    INSERT INTO Cart_Item (customer_id, product_id, quantity)
                    VALUES (:customer_id, :product_id, :quantity)
                """, {
                    "customer_id": customer_id,
                    "product_id": product_id,
                    "quantity": quantity
                })

        conn.commit()
        conn.close()
        return jsonify({"message": "Item added to cart"}), 200

    except Exception as e:
        print("Error in POST /cart:", e)
        return jsonify({"error": "Database error"}), 500
    

@app.route('/login', methods=['POST'])
@cross_origin()
def login():
    """
    Login using username and password.
    """
    data = request.get_json()

    # Validate input
    if not data.get("username") or not data.get("password"):
        return jsonify({"error": "Username and password are required"}), 400

    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database unavailable"}), 500

    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT customer_id
                FROM Customer
                WHERE username = :username AND password = :password
            """, {
                "username": data["username"],
                "password": data["password"]
            })

            row = cursor.fetchone()

        conn.close()

        if row:
            return jsonify({"customer_id": row[0]}), 200
        return jsonify({"error": "Invalid credentials"}), 401

    except Exception as e:
        print("Error in /login:", e)
        return jsonify({"error": "Database error"}), 500


@app.route('/customer/<int:customer_id>', methods=['GET'])
@cross_origin()
def get_customer(customer_id):
    """
    Return basic customer info for UI after login.
    Matches Customer(customer_id, name, username, email).
    """
    try:
        conn = get_db_connection()
        if conn is None:
            return jsonify({"error": "Database unavailable"}), 500

        cursor = conn.cursor()
        cursor.execute("""
            SELECT name, username, email
            FROM Customer
            WHERE customer_id = :customer_id
        """, {"customer_id": customer_id})
        row = cursor.fetchone()
        cursor.close()
        conn.close()

        if row:
            return jsonify({
                "name": row[0],
                "username": row[1],
                "email": row[2]
            }), 200
        else:
            return jsonify({"error": "Customer not found"}), 404
    except Exception as e:
        print("Error in /customer:", e)
        return jsonify({"error": "Database error"}), 500

@app.route('/register', methods=['POST'])
@cross_origin()
def register():
    """
    Register a new customer.
    Expects JSON: {name, username, password, email (optional)}.
    Returns {customer_id, name, username, email} on success.
    """
    data = request.get_json()
    name = data.get('name')
    username = data.get('username')
    password = data.get('password')
    email = data.get('email')

    if not name or not username or not password:
        return jsonify({"error": "Name, username, and password are required"}), 400

    try:
        conn = get_db_connection()
        if conn is None:
            return jsonify({"error": "Database unavailable"}), 500

        cursor = conn.cursor()

        # Insert new customer
        cursor.execute("""
            INSERT INTO Customer (customer_id, name, username, password, email)
            VALUES (customer_seq.NEXTVAL, :name, :username, :password, :email)
        """, {
            "name": name,
            "username": username,
            "password": password,
            "email": email
        })
        # Get the new customer_id
        cursor.execute("SELECT customer_seq.CURRVAL FROM dual")
        customer_id = cursor.fetchone()[0]
        conn.commit()
        cursor.close()
        conn.close()

        print(customer_id, name, username, password, email)
        return jsonify({
            "customer_id": customer_id,
            "name": name,
            "username": username,
            "email": email
        }), 201
    except Exception as e:
        print("Error in /register:", e)
        return jsonify({"error": "Database error"}), 500

@app.route('/checkout', methods=['POST'])
@cross_origin()
def checkout():

    """
    Minimal checkout: create transaction, add line items, and clear the customer's cart.
    """
    data = request.get_json() or {}
    customer_id = data.get('customer_id')

    if not customer_id:
        return jsonify({"error": "customer_id is required"}), 400

    try:
        conn = get_db_connection()
        if conn is None:
            return jsonify({"error": "Database unavailable"}), 500

        cursor = conn.cursor()
        
        # Calculate total amount from cart items
        cursor.execute("""
            SELECT SUM(ci.quantity * p.price)
            FROM Cart_Item ci
            JOIN Product p ON ci.product_id = p.product_id
            WHERE ci.customer_id = :customer_id
        """, {"customer_id": customer_id})
        total_amount = cursor.fetchone()[0]
        if total_amount is None:
            total_amount = 0
        
        # Insert new transaction
        cursor.execute("""
            INSERT INTO Transaction_sale (transaction_id, customer_id, transaction_date, total_amount)
            VALUES (transaction_seq.NEXTVAL, :customer_id, SYSDATE, :total_amount)
        """, {"customer_id": customer_id, "total_amount": total_amount})
        
        # Get the new transaction_id
        cursor.execute("SELECT transaction_seq.CURRVAL FROM dual")
        transaction_id = cursor.fetchone()[0]
        
        # Insert line items for each cart item
        cursor.execute("""
            INSERT INTO Line_item (transaction_id, product_id, quantity, subtotal)
            SELECT :transaction_id, ci.product_id, ci.quantity, ci.quantity * p.price
            FROM Cart_Item ci
            JOIN Product p ON ci.product_id = p.product_id
            WHERE ci.customer_id = :customer_id
        """, {"transaction_id": transaction_id, "customer_id": customer_id})
        
        cursor.execute("""
            DELETE FROM Cart_Item
            WHERE customer_id = :customer_id
        """, {"customer_id": customer_id})
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"message": "Checkout complete, cart cleared"}), 200
    except Exception as e:
        print("Error in /checkout:", e)
        return jsonify({"error": "Database error"}), 500

@app.route('/search', methods=['GET'])
@cross_origin()
def search_items():
    """
    Search products by substring match on product_name.
    Returns a list of {id, name, price, description}.
    """
    q = request.args.get('q', '').strip()
    if not q:
        return jsonify([])

    try:
        conn = get_db_connection()
        if conn is None:
            return jsonify([])

        #implemented to avoid sql injection
        cursor = conn.cursor()
        cursor.execute("""
            SELECT product_id, product_name, price, description
            FROM Product
            WHERE product_name LIKE '%' || :q || '%'
        """, {"q": q})
        rows = cursor.fetchall()

        results = [
            {"id": row[0], "name": row[1], "price": float(row[2]), "description": row[3]}
            for row in rows
        ]

        cursor.close()
        conn.close()
        return jsonify(results)
    except Exception as e:
        print("Error in /search:", e)
        return jsonify([])

@app.route('/purchases/<int:customer_id>', methods=['GET'])
@cross_origin()
def get_purchases(customer_id):
    """
    Get past purchases for a customer.

    Returns a list of objects with:
    {
      transaction_id,
      transaction_date,
      total_amount,
      product_id,
      product_name,
      quantity,
      subtotal,
      price
    }
    """
    try:
        conn = get_db_connection()
        if conn is None:
            return jsonify({"error": "Database unavailable"}), 500

        cursor = conn.cursor()
        cursor.execute("""
            SELECT
                ts.transaction_id,
                ts.transaction_date,
                ts.total_amount,
                li.product_id,
                p.product_name,
                p.price,
                li.quantity,
                li.subtotal
            FROM Transaction_Sale ts
            JOIN Line_item li
              ON ts.transaction_id = li.transaction_id
            JOIN Product p
              ON li.product_id = p.product_id
            WHERE ts.customer_id = :customer_id
            ORDER BY ts.transaction_date DESC, ts.transaction_id, li.product_id
        """, {"customer_id": customer_id})

        rows = cursor.fetchall()
        purchases = [
            {
                "transaction_id": r[0],
                "transaction_date": r[1].isoformat() if r[1] else None,
                "total_amount": float(r[2]) if r[2] is not None else 0.0,
                "product_id": r[3],
                "product_name": r[4],
                "price": float(r[5]) if r[5] is not None else 0.0,
                "quantity": r[6],
                "subtotal": float(r[7]) if r[7] is not None else 0.0,
            }
            for r in rows
        ]

        cursor.close()
        conn.close()
        return jsonify(purchases), 200
    except Exception as e:
        print("Error in /purchases:", e)
        return jsonify({"error": "Database error"}), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"}), 200

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, debug=True)
