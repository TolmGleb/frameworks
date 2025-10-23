const express = require('express');
const { getAllProjects, getProjectStats } = require('../controllers/projectsController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticateToken, getAllProjects);
router.get('/stats', authenticateToken, getProjectStats);

module.exports = router;