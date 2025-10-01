import React, { useState } from 'react';
import axios from 'axios';

const Login = ({ onLogin }) => {
  const [formData, setFormData] = useState({
    username: '',
    password: ''
  });
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post('/api/login', formData);
      onLogin(response.data.user, response.data.token);
    } catch (error) {
      setError('Неверные учетные данные');
    }
  };

  return (
    <div className="login-container">
      <form onSubmit={handleSubmit} className="login-form">
        <h2>Вход в систему</h2>
        {error && <div className="error">{error}</div>}
        <input
          type="text"
          placeholder="Имя пользователя"
          value={formData.username}
          onChange={(e) => setFormData({...formData, username: e.target.value})}
          required
        />
        <input
          type="password"
          placeholder="Пароль"
          value={formData.password}
          onChange={(e) => setFormData({...formData, password: e.target.value})}
          required
        />
        <button type="submit">Войти</button>
      </form>
    </div>
  );
};

export default Login;