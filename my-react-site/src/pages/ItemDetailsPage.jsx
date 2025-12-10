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
        <div className="item-image-section">
          {/* Placeholder for product image */}
          <div className="item-image-placeholder">
            <span>Product Image</span>
          </div>
        </div>
        <div className="item-info-section">
          <h1 className="item-title">{item.name}</h1>
          <p className="item-price">${item.price}</p>
          <p className="item-description">{item.description || 'No description available'}</p>
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
