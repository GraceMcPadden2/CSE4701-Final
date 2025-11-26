import React from 'react';
import cartData from '../data/cartData'; // Import the sample cart data
import backgroundImage from '../assets/background.jpg'; // Import the background image

const HomePage = ({ onItemClick }) => { // <-- added prop for click handler
  return (
    <>
      <div
        className="hero-wrap"
        style={{ backgroundImage: `url(${backgroundImage})` }}
        role="img"
        aria-label="Hero background"
      />
      <ul className="product-list">
        {cartData.map((item) => (
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
