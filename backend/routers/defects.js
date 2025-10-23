const express = require('express');
const { 
  getAllDefects, 
  createDefect, 
  updateDefectStatus, 
  getDefectComments, 
  addComment 
} = require('../controllers/defectsController');
const { authenticateToken, requireRole } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticateToken, getAllDefects);
router.post('/', authenticateToken, requireRole('менеджер'), createDefect);
router.patch('/:id/status', authenticateToken, updateDefectStatus);
router.get('/:defectId/comments', authenticateToken, getDefectComments);
router.post('/:defectId/comments', authenticateToken, addComment);

module.exports = router;