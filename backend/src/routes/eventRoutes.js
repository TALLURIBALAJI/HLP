import express from 'express';
import * as eventController from '../controllers/eventController.js';

const router = express.Router();

// Create event
router.post('/', eventController.createEvent);

// Get all events
router.get('/', eventController.getAllEvents);

// Register as volunteer
router.post('/:id/volunteer', eventController.registerVolunteer);

// Mark attendance (admin/organizer)
router.put('/:id/attendance', eventController.markAttendance);

// Complete event (organizer only)
router.put('/:id/complete', eventController.completeEvent);

export default router;
