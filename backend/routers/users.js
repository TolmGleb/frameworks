const express = require('express');
const { getAllUsers, getEngineers } = require('../controllers/usersController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticateToken, getAllUsers);
router.get('/engineers', authenticateToken, getEngineers);

module.exports = router;