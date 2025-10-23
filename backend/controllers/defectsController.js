const pool = require('../config/database');

const getAllDefects = async (req, res) => {
  try {
    const { project_id, status, priority } = req.query;
    
    let query = `
      SELECT d.*, p.name as project_name, 
             u1.first_name as author_first_name, u1.last_name as author_last_name,
             u2.first_name as assignee_first_name, u2.last_name as assignee_last_name
      FROM defects d
      LEFT JOIN projects p ON d.project_id = p.id
      LEFT JOIN users u1 ON d.author_id = u1.id
      LEFT JOIN users u2 ON d.assignee_id = u2.id
      WHERE 1=1
    `;
    const params = [];
    let paramCount = 0;

    if (project_id) {
      paramCount++;
      params.push(project_id);
      query += ` AND d.project_id = $${paramCount}`;
    }

    if (status) {
      paramCount++;
      params.push(status);
      query += ` AND d.status = $${paramCount}`;
    }

    if (priority) {
      paramCount++;
      params.push(priority);
      query += ` AND d.priority = $${paramCount}`;
    }

    query += ' ORDER BY d.created_at DESC';

    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Get defects error:', error);
    res.status(500).json({ error: 'Ошибка при получении дефектов' });
  }
};

const createDefect = async (req, res) => {
  try {
    const { title, description, project_id, priority, assignee_id, planned_completion_date } = req.body;
    
    const result = await pool.query(
      `INSERT INTO defects 
       (title, description, project_id, priority, author_id, assignee_id, planned_completion_date) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) 
       RETURNING *`,
      [title, description, project_id, priority, req.user.id, assignee_id, planned_completion_date]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Create defect error:', error);
    res.status(500).json({ error: 'Ошибка при создании дефекта' });
  }
};

const updateDefectStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const result = await pool.query(
      'UPDATE defects SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
      [status, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Дефект не найден' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Update defect error:', error);
    res.status(500).json({ error: 'Ошибка при обновлении дефекта' });
  }
};

const getDefectComments = async (req, res) => {
  try {
    const { defectId } = req.params;
    
    const result = await pool.query(
      `SELECT dc.*, u.first_name, u.last_name 
       FROM defect_comments dc 
       LEFT JOIN users u ON dc.author_id = u.id 
       WHERE dc.defect_id = $1 
       ORDER BY dc.created_at ASC`,
      [defectId]
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Get comments error:', error);
    res.status(500).json({ error: 'Ошибка при получении комментариев' });
  }
};

const addComment = async (req, res) => {
  try {
    const { defectId } = req.params;
    const { comment_text } = req.body;

    const result = await pool.query(
      'INSERT INTO defect_comments (defect_id, author_id, comment_text) VALUES ($1, $2, $3) RETURNING *',
      [defectId, req.user.id, comment_text]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Add comment error:', error);
    res.status(500).json({ error: 'Ошибка при добавлении комментария' });
  }
};

module.exports = {
  getAllDefects,
  createDefect,
  updateDefectStatus,
  getDefectComments,
  addComment
};