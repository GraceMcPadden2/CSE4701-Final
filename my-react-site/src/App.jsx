import { useState, useEffect } from 'react'
import './App.css'
import cartIcon from './assets/cart.svg'; 
import searchIcon from './assets/search.svg';
import HomePage from './pages/HomePage';
import CartPage from './pages/CartPage';
import ItemDetailsPage from './pages/ItemDetailsPage';
import Login from './pages/Login';
import CreateAccount from './pages/CreateAccount';

function App() {
  const [page, setPage] = useState('home');
  const [selectedItem, setSelectedItem] = useState(null);

  useEffect(() => {
    console.log('Current page:', page);
  }, [page]);

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
            onClick={(e) => e.stopPropagation()}
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
              e.stopPropagation();
              setPage('login');
            }}
          >
            Log in
          </div>
          <img
            src={cartIcon}
            alt="Shopping Cart"
            className="cart-icon"
            onClick={(e) => {
              e.stopPropagation();
              console.log('Cart icon clicked');
              setPage('cart');
            }}
          />
        </div>
        <div className="sub-banner">
        </div>
        {page === 'home' && <HomePage onItemClick={handleItemClick} />} 
        {page === 'cart' && <CartPage />}
        {page === 'item-details' && <ItemDetailsPage item={selectedItem} />}
        {page === 'login' && <Login onSwitchToCreateAccount={() => setPage('create-account')} />}
        {page === 'create-account' && <CreateAccount onSwitchToLogin={() => setPage('login')} />}
      </main>
      <footer className="site-footer">
        <div className="site-footer-inner">
        </div>
      </footer>
    </div>
  );
}

export default App;
