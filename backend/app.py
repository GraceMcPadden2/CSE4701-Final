import os
import cx_Oracle  #for Oracle DB connection
from flask import Flask, jsonify
from flask_cors import CORS, cross_origin  # Added: import cross_origin

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "http://localhost:5176"}})


# Added: Dummy database: list of fake items (for fallback)
dummy_items = [
    {"id": 1, "name": "Laptop", "price": 999.99},
    {"id": 2, "name": "Mouse", "price": 19.99},
    {"id": 3, "name": "Keyboard", "price": 49.99}
]

# Added: Dummy cart data (for fallback)
dummy_cart = [
    {"id": 1, "name": "Laptop", "price": 999.99, "quantity": 1},
    {"id": 2, "name": "Mouse", "price": 19.99, "quantity": 2}
]

#  Database connection setup
def get_db_connection():
    try:
        dsn = cx_Oracle.makedsn(
            os.getenv('DB_HOST', 'localhost'),
            int(os.getenv('DB_PORT', 1521)),
            os.getenv('DB_SID', 'XE')
        )
        return cx_Oracle.connect(
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            dsn=dsn
        )
    except Exception as e:
        # Log and return None when DB is not available
        print("DB connection failed:", e)
        return None

@app.route('/items', methods=['GET'])
@cross_origin()  # Added: explicit CORS for this route
def get_items():
    # Fetch from product table instead of dummy data
    try:
        conn = get_db_connection()
        if conn is None:
            # DB not available -> fallback
            return jsonify(dummy_items)

        cursor = conn.cursor()
        cursor.execute("SELECT product_id, name, price FROM product")
        rows = cursor.fetchall()
        items = [{"id": row[0], "name": row[1], "price": float(row[2])} for row in rows]
        cursor.close()
        conn.close()
        return jsonify(items)
    except Exception as e:
        # Fallback on any other error
        print("Error in /items:", e)
        return jsonify(dummy_items)

@app.route('/cart', methods=['GET'])
@cross_origin()  # Added: explicit CORS for this route
def get_cart():
    print("GET /cart called")  # debug: see this in the backend console
    print("Returning dummy_cart:", dummy_cart)
    return jsonify(dummy_cart)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"}), 200

if __name__ == '__main__':
    # bind explicitly and show port
    app.run(host='127.0.0.1', port=5000, debug=True)
