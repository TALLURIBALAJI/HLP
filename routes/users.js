// routes/users.js
import express from 'express';
import User from '../models/User.js';

const router = express.Router();

// Create a new user (signup or save user info)
router.post('/', async (req, res) => {
  try {
    const { name, email, phone, avatarUrl, location } = req.body;
    // basic validation
    if (!name || !email) return res.status(400).json({ error: 'name and email are required' });

    // upsert: if user with same email exists, return it; otherwise create new
    let user = await User.findOne({ email });
    if (user) return res.status(200).json(user);

    user = new User({
      name, email, phone, avatarUrl,
      location: location || { type: 'Point', coordinates: [0, 0] }
    });
    await user.save();
    res.status(201).json(user);
  } catch (err) {
    console.error(err);
    // duplicate email error handling
    if (err.code === 11000) return res.status(409).json({ error: 'Email already exists' });
    res.status(500).json({ error: 'Server error' });
  }
});

// Get user by id
router.get('/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id).lean();
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Update user (karma, profile, location etc.)
router.put('/:id', async (req, res) => {
  try {
    const updates = req.body;
    // prevent changing email to existing one (optional)
    const user = await User.findByIdAndUpdate(req.params.id, updates, { new: true });
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Leaderboard: top N users by karma
router.get('/leaderboard/top/:n', async (req, res) => {
  try {
    const n = Math.min(Number(req.params.n) || 10, 100);
    const topUsers = await User.find().sort({ karma: -1 }).limit(n).select('name karma level badges avatarUrl');
    res.json(topUsers);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

export default router;
