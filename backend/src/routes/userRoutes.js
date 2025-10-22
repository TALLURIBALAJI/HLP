import express from 'express';
import {
  createOrUpdateUser,
  getUserByFirebaseUid,
  updateUserKarma,
  getLeaderboard
} from '../controllers/userController.js';

const router = express.Router();

// GET /api/users/leaderboard/top - Get leaderboard (MUST be before /:firebaseUid)
router.get('/leaderboard/top', getLeaderboard);

// POST /api/users - Create or update user
router.post('/', createOrUpdateUser);

// GET /api/users/:firebaseUid - Get user by Firebase UID
router.get('/:firebaseUid', getUserByFirebaseUid);

// PATCH /api/users/:firebaseUid/karma - Update user karma
router.patch('/:firebaseUid/karma', updateUserKarma);

export default router;
