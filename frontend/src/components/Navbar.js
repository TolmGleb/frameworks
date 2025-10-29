import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import '../styles/components/Navbar.css';

const Navbar = ({ user, onLogout }) => {
  const location = useLocation();

  const isActive = (path) => {
    return location.pathname === path ? 'nav-link active' : 'nav-link';
  };

  return (
    <nav className="navbar">
      <div className="nav-links">
        <Link to="/" className="nav-brand">
          СистемаКонтроля
        </Link>
        <Link to="/" className={isActive('/')}>
          Панель управления
        </Link>
        <Link to="/defects" className={isActive('/defects')}>
          Дефекты
        </Link>
        <Link to="/projects" className={isActive('/projects')}>
          Проекты
        </Link>
      </div>

      <div className="nav-user">
        <div className="user-info">
          <span>{user.firstName} {user.lastName}</span>
          <span className="user-role">{user.role}</span>
        </div>
        <button onClick={onLogout} className="logout-btn">
          Выйти
        </button>
      </div>
    </nav>
  );
};

export default Navbar;