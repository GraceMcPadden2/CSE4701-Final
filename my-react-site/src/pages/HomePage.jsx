import React, { useState, useEffect } from 'react';
// import cartData from '../data/cartData'; // Removed: no longer needed
import backgroundImage from '../assets/background.jpg'; // Import the background image

const HomePage = ({ onItemClick }) => { // <-- added prop for click handler
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    console.log('Fetching items from Flask...');  // Added: debug log
    fetch('http://127.0.0.1:5000/items')
      .then(response => {
        console.log('Response received:', response);  // Added: debug log
        return response.json();
      })
      .then(data => {
        console.log('Data fetched:', data);  // Added: debug log
        setItems(data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Fetch error:', err);  // Added: debug log
        setError(err.message);
        setLoading(false);
      });
  }, []);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error}</p>;

  return (
    <>
      <div
        className="hero-wrap"
        style={{ backgroundImage: `url(${backgroundImage})` }}
        role="img"
        aria-label="Hero background"
      />
      <ul className="product-list">
        {items.map((item) => (
          <li key={item.id} onClick={() => onItemClick(item)}>
            <h2>{item.name}</h2>
            <p>Price: {item.price}</p>
          </li>
        ))}
      </ul>
    </>
  );
};

export default HomePage;
