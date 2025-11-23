import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'
import cartIcon from './assets/cart.svg'; // Add a shopping cart icon

function App() {
  const [page, setPage] = useState('home');

  const items = [
    { id: 1, name: 'Signed Poster', price: '$99' },
    { id: 2, name: 'UCONN Sweatshirt', price: '$59' },
    { id: 3, name: 'UCONN Mug', price: '$19' },
  ];

  return (
    <div>
      <div className="banner" onClick={() => setPage('home')}>
        Husky Marketplace
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
      {page === 'home' && (
        <ul>
          {items.map((item) => (
            <li key={item.id}>
              <h2>{item.name}</h2>
              <p>Price: {item.price}</p>
            </li>
          ))}
        </ul>
      )}
      {page === 'cart' && <h1>Cart</h1>}
    </div>
  );
}

export default App;
