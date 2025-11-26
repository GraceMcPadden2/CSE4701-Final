import React from 'react';
import cartData from '../data/cartData'; // Import the sample cart data

const CartPage = () => {
  return (
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
  );
};

export default CartPage;
