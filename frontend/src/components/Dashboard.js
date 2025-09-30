import React from 'react';
import { Link } from 'react-router-dom';

const Dashboard = ({ user }) => {
  return (
    <div className="dashboard">
      <h1>Панель управления</h1>
      <div className="dashboard-cards">
        <Link to="/defects" className="dashboard-card">
          <h3>Дефекты</h3>
          <p>Управление списком дефектов</p>
        </Link>
        <Link to="/projects" className="dashboard-card">
          <h3>Проекты</h3>
          <p>Просмотр строительных объектов</p>
        </Link>
        {user.role === 'менеджер' && (
          <Link to="/defects/new" className="dashboard-card">
            <h3>Создать дефект</h3>
            <p>Добавить новый дефект</p>
          </Link>
        )}
      </div>
    </div>
  );
};

export default Dashboard;