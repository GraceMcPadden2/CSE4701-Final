import React, { useState } from 'react';

const CreateAccount = ({ setCustomerId, setCustomerInfo, setPage, onSwitchToLogin }) => {
  const [name, setName] = useState('');
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    try {
      const response = await fetch('http://127.0.0.1:5000/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, username, password, email }),
      });

      const data = await response.json();
      if (!response.ok) {
        setError(data.error || 'Registration failed'); 
        return;
      }
      if (typeof setCustomerId === 'function') {
        setCustomerId(data.customer_id);
      }
      if (typeof setCustomerInfo === 'function') {
        setCustomerInfo({ name: data.name, username: data.username, email: data.email });
      }
      if (typeof setPage === 'function') {
        setPage('home');
      }
    } catch (err) {;
      console.log(err);
      setError('Network error: could not reach server');
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-form">
        <h1>Create Account</h1>
        {error && <p style={{ color: 'red' }}>{error}</p>}
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Name:</label>
            <input
              className="form-input"
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label>Username:</label>
            <input
              className="form-input"
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label>Email:</label>
            <input
              className="form-input"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>
          <div className="form-group">
            <label>Password:</label>
            <input
              className="form-input"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          <button type="submit" className="form-button">Create Account</button>
        </form>
        <p className="auth-link">
          Already have an account?{' '}
          <button onClick={onSwitchToLogin} className="link-button">Log In</button>
        </p>
      </div>
    </div>
  );
};

export default CreateAccount;
