import { useState, useEffect } from 'react'
import './App.css'
import cartIcon from './assets/cart.svg'; 
import searchIcon from './assets/search.svg';
import HomePage from './pages/HomePage';
import CartPage from './pages/CartPage';
import ItemDetailsPage from './pages/ItemDetailsPage';
import Login from './pages/Login';
import CreateAccount from './pages/CreateAccount';
import SearchPage from './pages/SearchPage';
import PastPurchasesPage from './pages/PastPurchasesPage';

function App() {
  const [currentPage, setCurrentPage] = useState('home'); // 'home' | 'search' | 'item' | 'cart' | 'purchases'
  const [selectedItem, setSelectedItem] = useState(null);
  const [customerId, setCustomerId] = useState(
    Number(localStorage.getItem('customerId')) || null
  );
  const [customerInfo, setCustomerInfo] = useState(
    JSON.parse(localStorage.getItem('customerInfo')) || null
  );
  const [searchQuery, setSearchQuery] = useState('');
  const [submittedQuery, setSubmittedQuery] = useState('');

  useEffect(() => {
    console.log('Current page:', currentPage);
  }, [currentPage]);

  const handleItemClick = (item) => {
    setSelectedItem(item);
    setCurrentPage('item');
  };

  const handleLogout = () => {
    setCustomerId(null);
    setCustomerInfo(null);
    localStorage.removeItem('customerId');
    localStorage.removeItem('customerInfo');
    setCurrentPage('home');
  };

  const handleSearchSubmit = () => {
    setSubmittedQuery(searchQuery);
    setCurrentPage('search');
  };

  const handleSwitchToCreateAccount = () => setCurrentPage('create-account');
  const handleSwitchToLogin = () => setCurrentPage('login');

  return (
    <div className="app-root">
      <main className="site-main">
        <div className="banner" onClick={() => setCurrentPage('home')}>
          Amazon
          <input
            type="text"
            placeholder="Search..."
            className="search-bar"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter') {
                handleSearchSubmit();
              }
            }}
            onClick={(e) => e.stopPropagation()}
          />
          <div
            className="search-icon"
            onClick={(e) => {
              e.stopPropagation();
              handleSearchSubmit();
            }}
          >
            <img src={searchIcon} alt="Search Icon" className="search-icon-img" />
          </div>
          <div
            className="login-section"
            onClick={(e) => {
              e.stopPropagation();
              if (customerId) {
                handleLogout();
              } else {
                setCurrentPage('login');
              }
            }}
          >
            {customerInfo ? `Hello, ${customerInfo.name}` : 'Log in'}
          </div>
          <img
            src={cartIcon}
            alt="Shopping Cart"
            className="cart-icon"
            onClick={(e) => {
              e.stopPropagation();
              console.log('Cart icon clicked');
              setCurrentPage('cart');
            }}
          />
        </div>
        <div className="sub-banner">
        </div>
        {currentPage === 'home' && <HomePage onItemClick={handleItemClick} />} 
        {currentPage === 'cart' && <CartPage customerId={customerId} setPage={setCurrentPage} />}
        {currentPage === 'item' && <ItemDetailsPage item={selectedItem} customerId={customerId} />}
        {currentPage === 'login' && <Login setCustomerId={(id) => {
          setCustomerId(id);
          localStorage.setItem('customerId', id);
        }} setCustomerInfo={(info) => {
          setCustomerInfo(info);
          localStorage.setItem('customerInfo', JSON.stringify(info));
        }} setPage={setCurrentPage} onSwitchToCreateAccount={handleSwitchToCreateAccount} />}
        {currentPage === 'create-account' && <CreateAccount setCustomerId={setCustomerId} setCustomerInfo={setCustomerInfo} setPage={setCurrentPage} onSwitchToLogin={handleSwitchToLogin} />}
        {currentPage === 'search' && <SearchPage query={submittedQuery} onItemClick={handleItemClick} />}
        {currentPage === 'purchases' && <PastPurchasesPage customerId={customerId} />}
      </main>
      <footer className="site-footer">
        <div className="site-footer-inner">
        </div>
      </footer>
    </div>
  );
}

export default App;
