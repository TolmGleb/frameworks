import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { defectsAPI, projectsAPI, usersAPI } from '../services/api';
import '../styles/components/DefectForm.css';

const DefectForm = ({ user }) => {
  const navigate = useNavigate();
  const [projects, setProjects] = useState([]);
  const [engineers, setEngineers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    project_id: '',
    priority: 'Средний',
    assignee_id: '',
    planned_completion_date: ''
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [projectsResponse, engineersResponse] = await Promise.all([
          projectsAPI.getAll(),
          usersAPI.getEngineers()
        ]);
        setProjects(projectsResponse.data);
        setEngineers(engineersResponse.data);
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };

    fetchData();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);

    try {
      await defectsAPI.create(formData);
      navigate('/defects');
    } catch (error) {
      console.error('Error creating defect:', error);
      alert('Ошибка при создании дефекта: ' + (error.response?.data?.error || 'Неизвестная ошибка'));
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  return (
    <div className="defect-form">
      <div className="container">
        <h1>Создание нового дефекта</h1>

        <form onSubmit={handleSubmit} className="form-card">
          <div className="form-group">
            <label className="form-label">Заголовок дефекта *</label>
            <input
              type="text"
              name="title"
              className="form-control"
              value={formData.title}
              onChange={handleChange}
              required
              placeholder="Краткое описание проблемы"
            />
          </div>

          <div className="form-group">
            <label className="form-label">Подробное описание *</label>
            <textarea
              name="description"
              className="form-control"
              value={formData.description}
              onChange={handleChange}
              required
              placeholder="Подробное описание дефекта, местоположение, возможные причины"
              rows="4"
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Проект *</label>
              <select
                name="project_id"
                className="form-control"
                value={formData.project_id}
                onChange={handleChange}
                required
              >
                <option value="">Выберите проект</option>
                {projects.map(project => (
                  <option key={project.id} value={project.id}>
                    {project.name}
                  </option>
                ))}
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Приоритет *</label>
              <select
                name="priority"
                className="form-control"
                value={formData.priority}
                onChange={handleChange}
                required
              >
                <option value="Низкий">Низкий</option>
                <option value="Средний">Средний</option>
                <option value="Высокий">Высокий</option>
                <option value="Критический">Критический</option>
              </select>
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Исполнитель</label>
              <select
                name="assignee_id"
                className="form-control"
                value={formData.assignee_id}
                onChange={handleChange}
              >
                <option value="">Не назначен</option>
                {engineers.map(engineer => (
                  <option key={engineer.id} value={engineer.id}>
                    {engineer.first_name} {engineer.last_name}
                  </option>
                ))}
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Плановый срок устранения</label>
              <input
                type="date"
                name="planned_completion_date"
                className="form-control"
                value={formData.planned_completion_date}
                onChange={handleChange}
              />
            </div>
          </div>

          <div className="form-actions">
            <button
              type="button"
              className="btn btn-secondary"
              onClick={() => navigate('/defects')}
              disabled={loading}
            >
              Отмена
            </button>
            <button
              type="submit"
              className="btn btn-primary"
              disabled={loading}
            >
              {loading ? 'Создание...' : 'Создать дефект'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default DefectForm;