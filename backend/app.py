import os
import oracledb  #for Oracle DB connection
from flask import Flask, jsonify, request  # Updated: added request import
from flask_cors import CORS, cross_origin  # Added: import cross_origin

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "http://localhost:5176"}})

#  Database connection setup
def get_db_connection():
    try:
        dsn = oracledb.makedsn(
            host="localhost",
            port=1521,
            service_name="FREE" 
        )

        return oracledb.connect(
            user="system",
            password="MyPassword123",
            dsn=dsn
        )

    except Exception as e:
        print("DB connection failed:", e)
        return None

@app.route('/items', methods=['GET'])
@cross_origin() 
def get_items():
    try:
        conn = get_db_connection()
        if conn is None:
            return jsonify([])

        cursor = conn.cursor()
        cursor.execute("SELECT product_id, name, price FROM product")
        rows = cursor.fetchall()
        items = [{"id": row[0], "name": row[1], "price": float(row[2])} for row in rows]
        cursor.close()
        conn.close()
        return jsonify(items)
    except Exception as e:
        print("Error in /items:", e)
        return jsonify([])

@app.route('/cart/<int:customer_id>', methods=['GET'])
@cross_origin() 
def get_cart(customer_id):
    print(f"GET /cart/{customer_id} called")  # debug: see this in the backend console
    try:
        conn = get_db_connection()
        if conn is None:
            return jsonify([])

        cursor = conn.cursor()
        cursor.execute("""
            SELECT ci.product_id, p.name, p.price, ci.quantity
            FROM Cart_Item ci
            JOIN Product p ON ci.product_id = p.product_id
            WHERE ci.customer_id = :customer_id
        """, {"customer_id": customer_id})
        rows = cursor.fetchall()
        cart_items = [{"id": row[0], "name": row[1], "price": float(row[2]), "quantity": row[3]} for row in rows]
        cursor.close()
        conn.close()
        print("Returning cart_items from DB:", cart_items)
        return jsonify(cart_items)
    except Exception as e:
        print("Error in /cart:", e)
        return jsonify([])

@app.route('/cart', methods=['POST'])
@cross_origin()
def add_to_cart():
    data = request.get_json()
    customer_id = data.get('customer_id')
    product_id = data.get('product_id')
    quantity = data.get('quantity')
    
    if not customer_id or not product_id or quantity is None:
        return jsonify({"error": "customer_id, product_id, and quantity are required"}), 400
    
    try:
        conn = get_db_connection()
        if conn is None:
            return jsonify({"error": "Database unavailable"}), 500

        cursor = conn.cursor()
        
        # Check if item already in cart
        cursor.execute("""
            SELECT quantity FROM Cart_Item
            WHERE customer_id = :customer_id AND product_id = :product_id
        """, {"customer_id": customer_id, "product_id": product_id})
        row = cursor.fetchone()
        
        if row:
            # Update quantity
            new_quantity = row[0] + quantity
            cursor.execute("""
                UPDATE Cart_Item
                SET quantity = :quantity
                WHERE customer_id = :customer_id AND product_id = :product_id
            """, {"quantity": new_quantity, "customer_id": customer_id, "product_id": product_id})
        else:
            # Insert new
            cursor.execute("""
                INSERT INTO Cart_Item (customer_id, product_id, quantity)
                VALUES (:customer_id, :product_id, :quantity)
            """, {"customer_id": customer_id, "product_id": product_id, "quantity": quantity})
        
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"message": "Item added to cart"}), 200
    except Exception as e:
        print("Error in /cart POST:", e)
        return jsonify({"error": "Database error"}), 500

@app.route('/login', methods=['POST'])
@cross_origin()
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    
    if not username or not password:
        return jsonify({"error": "Username and password are required"}), 400
    
    try:
        conn = get_db_connection()
        if conn is None:
            return jsonify({"error": "Database unavailable"}), 500

        cursor = conn.cursor()
        cursor.execute("""
            SELECT customer_id FROM Customer
            WHERE name = :username AND password = :password
        """, {"username": username, "password": password})
        row = cursor.fetchone()
        cursor.close()
        conn.close()
        
        if row:
            return jsonify({"customer_id": row[0]})
        else:
            return jsonify({"error": "Invalid credentials"}), 401
    except Exception as e:
        print("Error in /login:", e)
        return jsonify({"error": "Database error"}), 500

@app.route('/customer/<int:customer_id>', methods=['GET'])
@cross_origin()
def get_customer(customer_id):
    try:
        conn = get_db_connection()
        if conn is None:
            return jsonify({"error": "Database unavailable"}), 500

        cursor = conn.cursor()
        cursor.execute("""
            SELECT name, phone, loyalty_card_no FROM Customer
            WHERE customer_id = :customer_id
        """, {"customer_id": customer_id})
        row = cursor.fetchone()
        cursor.close()
        conn.close()
        
        if row:
            return jsonify({
                "name": row[0],
                "phone": row[1],
                "loyalty_card_no": row[2]
            })
        else:
            return jsonify({"error": "Customer not found"}), 404
    except Exception as e:
        print("Error in /customer:", e)
        return jsonify({"error": "Database error"}), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"}), 200

if __name__ == '__main__':
    # bind explicitly and show port
    app.run(host='127.0.0.1', port=5000, debug=True)
