import React, { useState } from 'react';

const ItemDetailsPage = ({ item, customerId }) => {
  const [quantity, setQuantity] = useState(1);
  const [message, setMessage] = useState('');

  if (!item) return <div className="item-details-error">No item selected</div>;

  const handleAddToCart = async () => {
    if (!customerId) {
      setMessage('Please log in to add items to cart.');
      return;
    }
    setMessage('');
    try {
      const response = await fetch('http://127.0.0.1:5000/cart', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          customer_id: customerId,
          product_id: item.id,
          quantity: parseInt(quantity)
        }),
      });
      const data = await response.json();
      if (response.ok) {
        setMessage('Item added to cart!');
      } else {
        setMessage(data.error || 'Failed to add item');
      }
    } catch (err) {
      setMessage('Network error');
    }
  };

  return (
    <div className="item-details-container">
      <div className="item-details-content">
        <div className="item-info-section">
          <h1 className="item-title">{item.name}</h1>
          <p className="item-price">${item.price}</p>
          <div className="description-section">
            <label htmlFor="description" className="description-label">Description:</label>
            <textarea
              id="description"
              value={item.description || 'No description available'}
              readOnly
              rows="4"
              cols="50"
              style={{
                width: '100%',
                padding: '10px',
                border: '1px solid #ccc',
                borderRadius: '4px',
                backgroundColor: '#f9f9f9',
                fontFamily: 'Arial, sans-serif',
                fontSize: '14px',
                resize: 'none'
              }}
              className="description-textarea"
            />
          </div>
          <div className="quantity-section">
            <label htmlFor="quantity" className="quantity-label">Quantity:</label>
            <input
              id="quantity"
              type="number"
              min="1"
              value={quantity}
              onChange={(e) => setQuantity(e.target.value)}
              className="quantity-input"
            />
          </div>
          <button onClick={handleAddToCart} className="add-to-cart-button">Add to Cart</button>
          {message && <p className={`message ${message.includes('added') ? 'success' : 'error'}`}>{message}</p>}
        </div>
      </div>
    </div>
  );
};

export default ItemDetailsPage;
