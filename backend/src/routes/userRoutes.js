import express from 'express';
import {
  createOrUpdateUser,
  getUserByFirebaseUid,
  updateUserKarma,
  getLeaderboard,
  registerOneSignalPlayerId,
  checkEmailExists
} from '../controllers/userController.js';

const router = express.Router();

// GET /api/users/leaderboard/top - Get leaderboard (MUST be before /:firebaseUid)
router.get('/leaderboard/top', getLeaderboard);

// GET /api/users/check-email - Check if email exists (MUST be before /:firebaseUid)
router.get('/check-email', checkEmailExists);

// POST /api/users - Create or update user
router.post('/', createOrUpdateUser);

// POST /api/users/onesignal/register - Register OneSignal Player ID
router.post('/onesignal/register', registerOneSignalPlayerId);

// GET /api/users/:firebaseUid - Get user by Firebase UID
router.get('/:firebaseUid', getUserByFirebaseUid);

// PATCH /api/users/:firebaseUid/karma - Update user karma
router.patch('/:firebaseUid/karma', updateUserKarma);

export default router;
