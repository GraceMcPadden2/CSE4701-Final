import React from 'react';

const ItemDetailsPage = ({ item }) => {
  if (!item) return <div>No item selected</div>;

  const handleAddToCart = () => {
    console.log(`Added ${item.name} to cart`); // Dummy action
  };

  return (
    <div>
      <h1>{item.name}</h1>
      <p>Price: {item.price}</p>
      <p>Quantity: {item.quantity}</p>
      <p>Description: {item.description || 'No description available'}</p>
      <button onClick={handleAddToCart}>Add to Cart</button>
    </div>
  );
};

export default ItemDetailsPage;
