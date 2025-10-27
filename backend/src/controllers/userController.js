import User from '../models/User.js';

// Create or update user from Firebase Auth
export const createOrUpdateUser = async (req, res) => {
  try {
    const { firebaseUid, username, email, mobile, profileImage } = req.body;

    if (!firebaseUid || !email) {
      return res.status(400).json({
        success: false,
        message: 'Firebase UID and email are required'
      });
    }

    // Check if user exists
    let user = await User.findOne({ firebaseUid });

    if (user) {
      // Update existing user
      user.username = username || user.username;
      user.email = email;
      user.mobile = mobile || user.mobile;
      user.profileImage = profileImage || user.profileImage;
      user.lastActive = Date.now();
      await user.save();

      return res.status(200).json({
        success: true,
        message: 'User updated successfully',
        data: user
      });
    } else {
      // Create new user
      user = await User.create({
        firebaseUid,
        username: username || email.split('@')[0],
        email,
        mobile,
        profileImage
      });

      return res.status(201).json({
        success: true,
        message: 'User created successfully',
        data: user
      });
    }
  } catch (error) {
    console.error('Error in createOrUpdateUser:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to create/update user'
    });
  }
};

// Get user by Firebase UID
export const getUserByFirebaseUid = async (req, res) => {
  try {
    const { firebaseUid } = req.params;

    const user = await User.findOne({ firebaseUid });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('Error in getUserByFirebaseUid:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get user'
    });
  }
};

// Update user karma
export const updateUserKarma = async (req, res) => {
  try {
    const { firebaseUid } = req.params;
    const { karmaChange } = req.body;

    const user = await User.findOneAndUpdate(
      { firebaseUid },
      { $inc: { karma: karmaChange } },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Karma updated successfully',
      data: user
    });
  } catch (error) {
    console.error('Error in updateUserKarma:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to update karma'
    });
  }
};

// Get leaderboard
export const getLeaderboard = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 100;

    const users = await User.find({ isActive: true })
      .sort({ karma: -1 })
      .limit(limit)
      .select('username email karma profileImage helpRequestsFulfilled');

    res.status(200).json({
      success: true,
      count: users.length,
      data: users
    });
  } catch (error) {
    console.error('Error in getLeaderboard:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get leaderboard'
    });
  }
};

// Register OneSignal Player ID for a user
export const registerOneSignalPlayerId = async (req, res) => {
  try {
    const { firebaseUid, playerId } = req.body;

    if (!firebaseUid || !playerId) {
      return res.status(400).json({
        success: false,
        message: 'Firebase UID and Player ID are required'
      });
    }

    const user = await User.findOne({ firebaseUid });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Add player ID if it doesn't exist
    if (!user.oneSignalPlayerIds.includes(playerId)) {
      user.oneSignalPlayerIds.push(playerId);
      await user.save();
    }

    res.status(200).json({
      success: true,
      message: 'Player ID registered successfully',
      data: user
    });
  } catch (error) {
    console.error('Error in registerOneSignalPlayerId:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to register Player ID'
    });
  }
};

// Check if email exists and get account type
export const checkEmailExists = async (req, res) => {
  try {
    const { email } = req.query;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email is required'
      });
    }

    const user = await User.findOne({ email: email.toLowerCase() });

    if (!user) {
      return res.status(200).json({
        success: true,
        exists: false,
        hasPassword: false,
        isGoogleUser: false
      });
    }

    // Check if user has profileImage from Google (indicates Google sign-in)
    const isGoogleUser = user.profileImage && user.profileImage.includes('googleusercontent.com');

    res.status(200).json({
      success: true,
      exists: true,
      hasPassword: !isGoogleUser, // If not Google user, assume they have password
      isGoogleUser: isGoogleUser
    });
  } catch (error) {
    console.error('Error in checkEmailExists:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to check email'
    });
  }
};
