import React, { useState, useEffect } from 'react';

const CartPage = () => {
  const [cartItems, setCartItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    console.log('CartPage mounted');
    console.log('Fetching cart from Flask...');
    fetch('http://127.0.0.1:5000/cart')
      .then(response => {
        console.log('Raw cart response:', response);
        if (!response.ok) {
          throw new Error(`HTTP ${response.status} ${response.statusText}`);
        }
        return response.json();
      })
      .then(data => {
        console.log('Cart data fetched:', data);
        setCartItems(data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Cart fetch error:', err);
        setError(err.message);
        setLoading(false);
      });
  }, []);

  useEffect(() => {
    console.log('cartItems state now:', cartItems);
  }, [cartItems]);

  if (loading) return <p>Loading cart...</p>;
  if (error) return <p>Error loading cart: {error}</p>;

  if (!cartItems || cartItems.length === 0) {
    return (
      <div>
        <h1>Cart</h1>
        <p>No items in cart (cartItems is empty).</p>
      </div>
    );
  }

  return (
    <div>
      <h1>Cart</h1>
      <ul>
        {cartItems.map((item) => (
          <li key={item.id}>
            <h2>{item.name}</h2>
            <p>Price: {item.price}</p>
            <p>Quantity: {item.quantity}</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default CartPage;
