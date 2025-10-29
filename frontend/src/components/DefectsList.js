import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { defectsAPI, projectsAPI, usersAPI } from '../services/api';
import '../styles/components/DefectsList.css';

const DefectsList = ({ user }) => {
  const [defects, setDefects] = useState([]);
  const [projects, setProjects] = useState([]);
  const [engineers, setEngineers] = useState([]);
  const [filters, setFilters] = useState({
    project_id: '',
    status: '',
    priority: '',
    assignee_id: ''
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, [filters]);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [defectsResponse, projectsResponse, engineersResponse] = await Promise.all([
        defectsAPI.getAll(filters),
        projectsAPI.getAll(),
        usersAPI.getEngineers()
      ]);

      setDefects(defectsResponse.data);
      setProjects(projectsResponse.data);
      setEngineers(engineersResponse.data);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleFilterChange = (key, value) => {
    setFilters(prev => ({
      ...prev,
      [key]: value
    }));
  };

  const handleStatusChange = async (defectId, newStatus) => {
    try {
      await defectsAPI.updateStatus(defectId, newStatus);
      fetchData(); // Обновляем список
    } catch (error) {
      console.error('Error updating status:', error);
    }
  };

  const getStatusBadgeClass = (status) => {
    const statusMap = {
      'Новая': 'status-new',
      'В работе': 'status-in-progress',
      'На проверке': 'status-on-review',
      'Закрыта': 'status-closed',
      'Отменена': 'status-cancelled'
    };
    return `status-badge ${statusMap[status] || ''}`;
  };

  const getPriorityBadgeClass = (priority) => {
    const priorityMap = {
      'Низкий': 'priority-low',
      'Средний': 'priority-medium',
      'Высокий': 'priority-high',
      'Критический': 'priority-critical'
    };
    return `priority-badge ${priorityMap[priority] || ''}`;
  };

  return (
    <div className="defects-list">
      <div className="container">
        <div className="defects-header">
          <h1>Список дефектов</h1>
          {user.role === 'менеджер' && (
            <Link to="/defects/new" className="btn btn-primary">
              Создать дефект
            </Link>
          )}
        </div>

        <div className="filters">
          <div className="filter-row">
            <div className="form-group">
              <label className="form-label">Проект</label>
              <select 
                className="form-control"
                value={filters.project_id}
                onChange={(e) => handleFilterChange('project_id', e.target.value)}
              >
                <option value="">Все проекты</option>
                {projects.map(project => (
                  <option key={project.id} value={project.id}>
                    {project.name}
                  </option>
                ))}
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Статус</label>
              <select 
                className="form-control"
                value={filters.status}
                onChange={(e) => handleFilterChange('status', e.target.value)}
              >
                <option value="">Все статусы</option>
                <option value="Новая">Новая</option>
                <option value="В работе">В работе</option>
                <option value="На проверке">На проверке</option>
                <option value="Закрыта">Закрыта</option>
                <option value="Отменена">Отменена</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Приоритет</label>
              <select 
                className="form-control"
                value={filters.priority}
                onChange={(e) => handleFilterChange('priority', e.target.value)}
              >
                <option value="">Все приоритеты</option>
                <option value="Низкий">Низкий</option>
                <option value="Средний">Средний</option>
                <option value="Высокий">Высокий</option>
                <option value="Критический">Критический</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Исполнитель</label>
              <select 
                className="form-control"
                value={filters.assignee_id}
                onChange={(e) => handleFilterChange('assignee_id', e.target.value)}
              >
                <option value="">Все исполнители</option>
                {engineers.map(engineer => (
                  <option key={engineer.id} value={engineer.id}>
                    {engineer.first_name} {engineer.last_name}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>

        {loading ? (
          <div className="text-center">Загрузка дефектов...</div>
        ) : defects.length === 0 ? (
          <div className="empty-state">
            <h3>Дефекты не найдены</h3>
            <p>Попробуйте изменить параметры фильтрации</p>
          </div>
        ) : (
          <div className="defects-grid">
            {defects.map(defect => (
              <div key={defect.id} className="defect-item">
                <div className="defect-header">
                  <h3 className="defect-title">{defect.title}</h3>
                  <div className="defect-meta">
                    <span className={getStatusBadgeClass(defect.status)}>
                      {defect.status}
                    </span>
                    <span className={getPriorityBadgeClass(defect.priority)}>
                      {defect.priority}
                    </span>
                  </div>
                </div>

                <div className="defect-description">
                  {defect.description}
                </div>

                <div className="defect-info">
                  <div><strong>Проект:</strong> {defect.project_name}</div>
                  <div><strong>Автор:</strong> {defect.author_first_name} {defect.author_last_name}</div>
                  {defect.assignee_first_name && (
                    <div><strong>Исполнитель:</strong> {defect.assignee_first_name} {defect.assignee_last_name}</div>
                  )}
                  {defect.planned_completion_date && (
                    <div><strong>Срок:</strong> {new Date(defect.planned_completion_date).toLocaleDateString('ru-RU')}</div>
                  )}
                </div>

                <div className="defect-footer">
                  <span>
                    Создан: {new Date(defect.created_at).toLocaleDateString('ru-RU')}
                  </span>
                  
                  {(user.role === 'менеджер' || user.role === 'инженер') && (
                    <div className="defect-actions">
                      <select 
                        value={defect.status}
                        onChange={(e) => handleStatusChange(defect.id, e.target.value)}
                        className="form-control"
                        style={{ width: 'auto' }}
                      >
                        <option value="Новая">Новая</option>
                        <option value="В работе">В работе</option>
                        <option value="На проверке">На проверке</option>
                        <option value="Закрыта">Закрыта</option>
                        <option value="Отменена">Отменена</option>
                      </select>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default DefectsList;