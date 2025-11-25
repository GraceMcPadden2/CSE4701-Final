import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'
import cartIcon from './assets/cart.svg'; 
import searchIcon from './assets/search.svg'; // Import the search icon
import cartData from './data/cartData'; // Import the sample cart data
import backgroundImage from './assets/background.jpg'; // <-- new import

function App() {
  const [page, setPage] = useState('home');

  return (
    <div className="app-root">
      <main className="site-main">
        <div className="banner" onClick={() => setPage('home')}>
          Amazon
          <input
            type="text"
            placeholder="Search..."
            className="search-bar"
            onClick={(e) => e.stopPropagation()} // Prevent triggering the banner click
          />
          <div
            className="search-icon"
            onClick={(e) => {
              e.stopPropagation();
              console.log('Search icon clicked');
            }}
          >
            <img src={searchIcon} alt="Search Icon" className="search-icon-img" />
          </div>
          <div
            className="login-section"
            onClick={(e) => {
              e.stopPropagation(); // do not trigger banner click
              console.log('Log in clicked');
            }}
          >
            Log in
          </div>
          <img
            src={cartIcon}
            alt="Shopping Cart"
            className="cart-icon"
            onClick={(e) => {
              e.stopPropagation(); // Prevent triggering the banner click
              setPage('cart');
            }}
          />
        </div>
        <div className="sub-banner">
        </div>
        {page === 'home' && (
          <>
            <div
              className="hero-wrap"
              style={{ backgroundImage: `url(${backgroundImage})` }}
              role="img"
              aria-label="Hero background"
            />
            <ul className="product-list">
              {cartData.map((item) => (
                <li key={item.id}>
                  <h2>{item.name}</h2>
                  <p>Price: {item.price}</p>
                </li>
              ))}
            </ul>
          </>
        )}
        {page === 'cart' && (
          <div>
            <h1>Cart</h1>
            <ul>
              {cartData.map((item) => (
                <li key={item.id}>
                  <h2>{item.name}</h2>
                  <p>Price: {item.price}</p>
                  <p>Quantity: {item.quantity}</p>
                </li>
              ))}
            </ul>
          </div>
        )}
      </main>
      <footer className="site-footer">
        <div className="site-footer-inner">
        </div>
      </footer>
    </div>
  );
}

export default App;
