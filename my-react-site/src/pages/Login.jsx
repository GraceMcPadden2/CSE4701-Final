import React, { useState } from 'react';

const Login = ({ setCustomerId, setCustomerInfo, setPage, onSwitchToCreateAccount }) => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    try {
      const response = await fetch('http://127.0.0.1:5000/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password }),
      });
      const data = await response.json();
      if (response.ok) {
        setCustomerId(data.customer_id);
        // Fetch customer info
        const infoResponse = await fetch(`http://127.0.0.1:5000/customer/${data.customer_id}`);
        const infoData = await infoResponse.json();
        if (infoResponse.ok) {
          setCustomerInfo(infoData);
          setPage('home');
        } else {
          setError('Failed to fetch user info');
        }
      } else {
        setError(data.error || 'Login failed');
      }
    } catch (err) {
      setError('Network error');
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-form">
        <h1>Log In</h1>
        {error && <p style={{ color: 'red' }}>{error}</p>}
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Username:</label>
            <input
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
              className="form-input"
            />
          </div>
          <div className="form-group">
            <label>Password:</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="form-input"
            />
          </div>
          <button type="submit" className="form-button">Log In</button>
        </form>
        <p className="auth-link">Don't have an account? <button onClick={onSwitchToCreateAccount} className="link-button">Create Account</button></p>
      </div>
    </div>
  );
};

export default Login;
