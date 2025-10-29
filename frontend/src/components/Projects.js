import React, { useState, useEffect } from 'react';
import { projectsAPI } from '../services/api';
import '../styles/components/Projects.css';

const Projects = ({ user }) => {
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchProjects = async () => {
      try {
        const response = await projectsAPI.getAll();
        setProjects(response.data);
      } catch (error) {
        console.error('Error fetching projects:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchProjects();
  }, []);

  if (loading) {
    return <div className="projects">Загрузка проектов...</div>;
  }

  return (
    <div className="projects">
      <div className="container">
        <h1>Строительные проекты</h1>
        
        <div className="projects-grid">
          {projects.map(project => (
            <div key={project.id} className="project-card">
              <div className="project-header">
                <h3>{project.name}</h3>
                <div className="project-address">{project.address}</div>
              </div>
              
              <div className="project-body">
                <div className="project-description">
                  {project.description}
                </div>
                
                <div className="project-stats">
                  <div className="stat">
                    <span className="stat-value">{project.total_defects}</span>
                    <span className="stat-label">Всего</span>
                  </div>
                  <div className="stat">
                    <span className="stat-value">{project.new_defects}</span>
                    <span className="stat-label">Новых</span>
                  </div>
                  <div className="stat">
                    <span className="stat-value">{project.closed_defects}</span>
                    <span className="stat-label">Завершено</span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {projects.length === 0 && (
          <div className="empty-state">
            <h3>Проекты не найдены</h3>
            <p>В системе пока нет активных строительных проектов</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default Projects;