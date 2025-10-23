const pool = require('../config/database');

const getAllUsers = async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, username, first_name, last_name, role FROM users WHERE is_active = true ORDER BY first_name, last_name'
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Ошибка при получении пользователей' });
  }
};

const getEngineers = async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, first_name, last_name FROM users WHERE role = $1 AND is_active = true ORDER BY first_name, last_name',
      ['инженер']
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Get engineers error:', error);
    res.status(500).json({ error: 'Ошибка при получении инженеров' });
  }
};

module.exports = {
  getAllUsers,
  getEngineers
};