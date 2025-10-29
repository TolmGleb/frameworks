import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { projectsAPI } from '../services/api';
import '../styles/components/Dashboard.css';

const Dashboard = ({ user }) => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await projectsAPI.getStats();
        setStats(response.data);
      } catch (error) {
        console.error('Error fetching stats:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  if (loading) {
    return <div className="dashboard">Загрузка статистики...</div>;
  }

  return (
    <div className="dashboard">
      <div className="container">
        <h1>Панель управления</h1>
        <p>Добро пожаловать, {user.firstName} {user.lastName}!</p>

        {stats && (
          <div className="stats-grid">
            <div className="stat-card">
              <span className="stat-number">{stats.total_defects}</span>
              <span className="stat-label">Всего дефектов</span>
            </div>
            <div className="stat-card">
              <span className="stat-number">{stats.new_defects}</span>
              <span className="stat-label">Новых</span>
            </div>
            <div className="stat-card">
              <span className="stat-number">{stats.in_progress_defects}</span>
              <span className="stat-label">В работе</span>
            </div>
            <div className="stat-card">
              <span className="stat-number">{stats.critical_defects}</span>
              <span className="stat-label">Критических</span>
            </div>
          </div>
        )}

        <div className="dashboard-cards">
          <Link to="/defects" className="dashboard-card">
            <h3>Дефекты</h3>
            <p>Просмотр и управление списком дефектов строительных объектов</p>
          </Link>

          <Link to="/projects" className="dashboard-card">
            <h3>Проекты</h3>
            <p>Информация о строительных объектах и их статистика</p>
          </Link>

          {user.role === 'менеджер' && (
            <Link to="/defects/new" className="dashboard-card">
              <h3>Создать дефект</h3>
              <p>Добавить новый дефект в систему</p>
            </Link>
          )}

          <div className="dashboard-card">
            <h3>Отчеты</h3>
            <p>Аналитика и отчетность по дефектам (в разработке)</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;