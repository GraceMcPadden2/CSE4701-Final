import React, { useState, useEffect } from 'react';

const SearchPage = ({ query, onItemClick }) => {
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (query) {
      fetch(`http://127.0.0.1:5000/search?q=${encodeURIComponent(query)}`)
        .then(response => response.json())
        .then(data => {
          setResults(data);
          setLoading(false);
        })
        .catch(err => {
          setError(err.message);
          setLoading(false);
        });
    } else {
      setResults([]);
      setLoading(false);
    }
  }, [query]);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error}</p>;

  return (
    <div style={{ marginTop: '5px' }}>
      <ul
        style={{
          display: 'block',
          width: '100%',
          padding: 0,
          margin: 5,
          listStyle: 'none',
        }}
      >
        {results.map((item) => (
          <li
            key={item.id}
            onClick={() => onItemClick(item)}
            style={{
              width: 'calc(100% - 40px)',
              padding: '20px',
              marginBottom: '10px',
              marginRight: '40px',
              background: '#fff',
              border: '1px solid #ddd',
              borderRadius: '5px',
              boxSizing: 'border-box',
            }}
          >
            <h2>{item.name}</h2>
            <p>Price: {item.price}</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default SearchPage;
