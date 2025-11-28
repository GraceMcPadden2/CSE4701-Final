import os
import cx_Oracle  # Added: for Oracle DB connection
from flask import Flask, jsonify
from flask_cors import CORS  # Added: for CORS support

app = Flask(__name__)
CORS(app)  # Added: enable CORS for all routes

# Added: Database connection setup
def get_db_connection():
    dsn = cx_Oracle.makedsn(os.getenv('DB_HOST', 'localhost'), os.getenv('DB_PORT', 1521), os.getenv('DB_SID', 'XE'))
    return cx_Oracle.connect(user=os.getenv('DB_USER'), password=os.getenv('DB_PASSWORD'), dsn=dsn)

@app.route('/items', methods=['GET'])
def get_items():
    # Replaced: Fetch from product table instead of dummy data
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT product_id, name, price FROM product")
        rows = cursor.fetchall()
        items = [{"id": row[0], "name": row[1], "price": float(row[2])} for row in rows]
        cursor.close()
        conn.close()
        return jsonify(items)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/cart', methods=['GET'])
def get_cart():
    # Replaced: Fetch cart items from line_item joined with product for a sample transaction (e.g., latest)
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT li.product_id, p.name, p.price, li.quantity
            FROM line_item li
            JOIN product p ON li.product_id = p.product_id
            WHERE li.transaction_id = (SELECT MAX(transaction_id) FROM transaction_sale)
        """)
        rows = cursor.fetchall()
        cart = [{"id": row[0], "name": row[1], "price": float(row[2]), "quantity": row[3]} for row in rows]
        cursor.close()
        conn.close()
        return jsonify(cart)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
