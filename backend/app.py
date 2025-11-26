from flask import Flask, jsonify
from flask_cors import CORS  # Added: for CORS support

app = Flask(__name__)
CORS(app)  # Added: enable CORS for all routes

# Dummy database: list of fake items
dummy_items = [
    {"id": 1, "name": "Laptop", "price": 999.99},
    {"id": 2, "name": "Mouse", "price": 19.99},
    {"id": 3, "name": "Keyboard", "price": 49.99}
]

@app.route('/items', methods=['GET'])
def get_items():
    return jsonify(dummy_items)

if __name__ == '__main__':
    app.run(debug=True)
