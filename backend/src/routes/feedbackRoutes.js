import express from 'express';
import * as feedbackController from '../controllers/feedbackController.js';

const router = express.Router();

// Submit feedback/rating
router.post('/', feedbackController.submitFeedback);

// Get user feedback
router.get('/user/:firebaseUid', feedbackController.getUserFeedback);

export default router;
