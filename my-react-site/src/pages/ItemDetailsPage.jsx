import React, { useState } from 'react';

const ItemDetailsPage = ({ item, customerId }) => {
  const [quantity, setQuantity] = useState(1);
  const [message, setMessage] = useState('');

  if (!item) return <div>No item selected</div>;

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
    <div>
      <h1>{item.name}</h1>
      <p>Price: {item.price}</p>
      <p>Description: {item.description || 'No description available'}</p>
      <div>
        <label>Quantity:</label>
        <input
          type="number"
          min="1"
          value={quantity}
          onChange={(e) => setQuantity(e.target.value)}
        />
      </div>
      <button onClick={handleAddToCart}>Add to Cart</button>
      {message && <p>{message}</p>}
    </div>
  );
};

export default ItemDetailsPage;
