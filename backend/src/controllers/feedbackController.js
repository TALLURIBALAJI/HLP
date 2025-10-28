import Feedback from '../models/Feedback.js';
import User from '../models/User.js';
import HelpRequest from '../models/HelpRequest.js';
import { sendNotificationToUser } from '../services/notificationService.js';

// Submit feedback/rating
export const submitFeedback = async (req, res) => {
  try {
    const { firebaseUid, helpRequestId, rating, comment } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5'
      });
    }

    // Find the user submitting feedback
    const fromUser = await User.findOne({ firebaseUid });
    if (!fromUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Find the help request to determine who to rate
    const helpRequest = await HelpRequest.findById(helpRequestId);
    if (!helpRequest) {
      return res.status(404).json({
        success: false,
        message: 'Help request not found'
      });
    }

    // Determine who to rate (if you're the requester, rate the helper; if you're the helper, rate the requester)
    let toUserId;
    if (helpRequest.userId.toString() === fromUser._id.toString()) {
      // Requester rating the helper
      toUserId = helpRequest.helperId;
    } else if (helpRequest.helperId && helpRequest.helperId.toString() === fromUser._id.toString()) {
      // Helper rating the requester
      toUserId = helpRequest.userId;
    } else {
      return res.status(403).json({
        success: false,
        message: 'You are not authorized to rate this help request'
      });
    }

    // Check if feedback already exists
    const existingFeedback = await Feedback.findOne({
      helpRequestId,
      fromUserId: fromUser._id
    });

    if (existingFeedback) {
      return res.status(400).json({
        success: false,
        message: 'You have already submitted feedback for this help request'
      });
    }

    // Create feedback
    const feedback = await Feedback.create({
      helpRequestId,
      fromUserId: fromUser._id,
      toUserId,
      rating,
      comment
    });

    // Award +5 karma points if rating >= 4
    if (rating >= 4) {
      await User.findByIdAndUpdate(toUserId, {
        $inc: { karma: 5 }
      });

      // Notify the user about positive feedback
      const toUser = await User.findById(toUserId);
      if (toUser && toUser.firebaseUid) {
        sendNotificationToUser(
          toUser.firebaseUid,
          '⭐ Positive Feedback Received!',
          `You received a ${rating}-star rating and earned +5 karma points!`,
          {
            type: 'positive_feedback',
            karmaEarned: 5,
            rating
          }
        ).catch(err => console.error('Notification error:', err));
      }
    }

    res.status(201).json({
      success: true,
      message: 'Feedback submitted successfully',
      data: feedback
    });
  } catch (error) {
    console.error('Error in submitFeedback:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to submit feedback'
    });
  }
};

// Get feedback for a user
export const getUserFeedback = async (req, res) => {
  try {
    const { firebaseUid } = req.params;

    const user = await User.findOne({ firebaseUid });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const feedback = await Feedback.find({ toUserId: user._id })
      .populate('fromUserId', 'username profileImage')
      .populate('helpRequestId', 'title')
      .sort({ createdAt: -1 });

    // Calculate average rating
    const avgRating = feedback.length > 0
      ? feedback.reduce((sum, f) => sum + f.rating, 0) / feedback.length
      : 0;

    res.status(200).json({
      success: true,
      data: {
        feedback,
        averageRating: avgRating.toFixed(1),
        totalFeedback: feedback.length
      }
    });
  } catch (error) {
    console.error('Error in getUserFeedback:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get feedback'
    });
  }
};
