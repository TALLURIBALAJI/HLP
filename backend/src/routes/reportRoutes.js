import express from 'express';
import * as reportController from '../controllers/reportController.js';

const router = express.Router();

// Submit report
router.post('/', reportController.submitReport);

// Get all reports (admin)
router.get('/', reportController.getAllReports);

// Verify report (admin)
router.put('/:id/verify', reportController.verifyReport);

export default router;
