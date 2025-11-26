import { useState } from 'react'
import './App.css'
import cartIcon from './assets/cart.svg'; 
import searchIcon from './assets/search.svg'; // Import the search icon
import cartData from './data/cartData'; // Import the sample cart data
import HomePage from './pages/HomePage'; // <-- existing import
import CartPage from './pages/CartPage'; // <-- existing import
import ItemDetailsPage from './pages/ItemDetailsPage'; // <-- existing import
import Login from './pages/Login'; // <-- new import

function App() {
  const [page, setPage] = useState('home');
  const [selectedItem, setSelectedItem] = useState(null); // <-- new state for selected item

  const handleItemClick = (item) => {
    setSelectedItem(item);
    setPage('item-details');
  };

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
              setPage('login'); // <-- changed to navigate to login
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
        {page === 'home' && <HomePage onItemClick={handleItemClick} />} 
        {page === 'cart' && <CartPage />}
        {page === 'item-details' && <ItemDetailsPage item={selectedItem} />}
        {page === 'login' && <Login />}
      </main>
      <footer className="site-footer">
        <div className="site-footer-inner">
        </div>
      </footer>
    </div>
  );
}

export default App;
