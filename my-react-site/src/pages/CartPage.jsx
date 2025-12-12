import React, { useState, useEffect } from 'react';
// import { useNavigate } from 'react-router-dom'; // remove

const CartPage = ({ customerId, setPage }) => {
  const [cartItems, setCartItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [checkoutMessage, setCheckoutMessage] = useState('');
  const [checkingOut, setCheckingOut] = useState(false); // fake wait flag

  // const navigate = useNavigate(); // remove

  useEffect(() => {
    if (!customerId) {
      setLoading(false);
      return;
    }

    fetch(`http://127.0.0.1:5000/cart/${customerId}`)
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP ${response.status} ${response.statusText}`);
        }
        return response.json();
      })
      .then(data => {
        setCartItems(Array.isArray(data) ? data : []); // ensure array
        setLoading(false);
      })
      .catch(err => {
        setError(err.message);
        setLoading(false);
      });
  }, [customerId]);

  const handleCheckout = async () => {
    try {
      setCheckingOut(true);          // start fake wait
      setCheckoutMessage('');        // clear any previous message

      const response = await fetch("http://127.0.0.1:5000/checkout", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ customer_id: customerId }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || response.statusText);
      }

      // Simulate a delay (e.g., 1 second) before showing success and clearing cart
      setTimeout(() => {
        setCheckoutMessage("Checkout successful!");
        setCartItems([]);
        setCheckingOut(false);
      }, 200);
    } catch (err) {
      setCheckoutMessage("Checkout failed: " + err.message);
      setCheckingOut(false);
    }
  };

  if (!customerId) {
    return (
      <div>
        <h1>Cart</h1>
      </div>
    );
  }

  if (loading) return <p>Loading cart...</p>;
  if (error) return <p>Error loading cart: {error}</p>;

  return (
    <div>
      <h1>Cart</h1>
      <ul>
        {(cartItems || []).map(item => (
          <li key={item.id}>
            <h2>{item.name}</h2>
            <p>Price: {item.price}</p>
            <p>Quantity: {item.quantity}</p>
          </li>
        ))}
      </ul>
      {cartItems.length > 0 && (
        <div style={{ textAlign: 'center' }}>
          <button
            onClick={handleCheckout}
            disabled={checkingOut}
            style={{
              backgroundColor: '#131921',
              color: 'white',
              padding: '10px 20px',
              border: 'none',
              borderRadius: '5px',
              cursor: checkingOut ? 'default' : 'pointer',
              opacity: checkingOut ? 0.7 : 1,
            }}
          >
            {checkingOut ? 'Processing...' : 'Checkout'}
          </button>
        </div>
      )}
      <div style={{ textAlign: 'center', marginTop: '10px' }}>
        <button
          onClick={() => setPage('purchases')}
          style={{
            backgroundColor: '#131921',
            color: 'white',
            padding: '10px 20px',
            border: 'none',
            borderRadius: '5px',
            cursor: 'pointer',
          }}
        >
          View Past Purchases
        </button>
      </div>
      {checkoutMessage && (
        <p style={{ textAlign: 'center', marginTop: '10px' }}>
          {checkoutMessage}
        </p>
      )}
    </div>
  );
};

export default CartPage;
