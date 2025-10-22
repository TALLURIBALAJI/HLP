import express from 'express';
import {
  createHelpRequest,
  getAllHelpRequests,
  getHelpRequestById,
  acceptHelpRequest,
  completeHelpRequest,
  getNearbyHelpRequests,
  updateHelpRequest,
  deleteHelpRequest
} from '../controllers/helpRequestController.js';

const router = express.Router();

// POST /api/help-requests - Create a new help request
router.post('/', createHelpRequest);

// GET /api/help-requests - Get all help requests (with filters)
router.get('/', getAllHelpRequests);

// GET /api/help-requests/nearby - Get nearby help requests
router.get('/nearby', getNearbyHelpRequests);

// GET /api/help-requests/:id - Get help request by ID
router.get('/:id', getHelpRequestById);

// PATCH /api/help-requests/:id/accept - Accept help request
router.patch('/:id/accept', acceptHelpRequest);

// PATCH /api/help-requests/:id/complete - Complete help request
router.patch('/:id/complete', completeHelpRequest);

// PATCH /api/help-requests/:id - Update help request
router.patch('/:id', updateHelpRequest);

// DELETE /api/help-requests/:id - Delete help request
router.delete('/:id', deleteHelpRequest);

export default router;
