const pool = require('../config/database');

const getAllProjects = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT p.*, 
              COUNT(d.id) as total_defects,
              COUNT(CASE WHEN d.status = 'Новая' THEN 1 END) as new_defects,
              COUNT(CASE WHEN d.status = 'В работе' THEN 1 END) as in_progress_defects,
              COUNT(CASE WHEN d.status IN ('Закрыта', 'Отменена') THEN 1 END) as closed_defects
       FROM projects p
       LEFT JOIN defects d ON p.id = d.project_id
       WHERE p.is_active = true
       GROUP BY p.id
       ORDER BY p.created_at DESC`
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Get projects error:', error);
    res.status(500).json({ error: 'Ошибка при получении проектов' });
  }
};

const getProjectStats = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 
        COUNT(*) as total_defects,
        COUNT(CASE WHEN status = 'Новая' THEN 1 END) as new_defects,
        COUNT(CASE WHEN status = 'В работе' THEN 1 END) as in_progress_defects,
        COUNT(CASE WHEN status = 'На проверке' THEN 1 END) as on_review_defects,
        COUNT(CASE WHEN status = 'Закрыта' THEN 1 END) as closed_defects,
        COUNT(CASE WHEN status = 'Отменена' THEN 1 END) as cancelled_defects,
        COUNT(CASE WHEN priority = 'Критический' THEN 1 END) as critical_defects,
        COUNT(CASE WHEN priority = 'Высокий' THEN 1 END) as high_defects
       FROM defects`
    );
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({ error: 'Ошибка при получении статистики' });
  }
};

module.exports = {
  getAllProjects,
  getProjectStats
};