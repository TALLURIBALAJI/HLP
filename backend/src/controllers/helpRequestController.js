import HelpRequest from '../models/HelpRequest.js';
import User from '../models/User.js';
import { sendNotificationExceptUser, sendNotificationToUser } from '../services/notificationService.js';

// Create a new help request
export const createHelpRequest = async (req, res) => {
  try {
    const { firebaseUid, title, description, category, urgency, location } = req.body;

    // Find user by Firebase UID
    const user = await User.findOne({ firebaseUid });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const helpRequest = await HelpRequest.create({
      userId: user._id,
      title,
      description,
      category,
      urgency,
      location
    });

    // Update user's help requests count and award karma points
    await User.findByIdAndUpdate(user._id, {
      $inc: { 
        helpRequestsCreated: 1,
        karma: 2  // +2 points for creating a help request
      }
    });

    // Send notification to all users except the creator
    sendNotificationExceptUser(
      firebaseUid,
      '🆘 New Help Request',
      `${title} - ${category}`,
      {
        type: 'new_help_request',
        requestId: helpRequest._id.toString(),
        category: category
      }
    ).catch(err => console.error('Notification error:', err));

    res.status(201).json({
      success: true,
      message: 'Help request created successfully',
      data: helpRequest
    });
  } catch (error) {
    console.error('Error in createHelpRequest:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to create help request'
    });
  }
};

// Get all help requests
export const getAllHelpRequests = async (req, res) => {
  try {
    const { status, category, userId, limit = 50, page = 1 } = req.query;

    const query = {};
    if (status) query.status = status;
    if (category) query.category = category;
    
    // Support filtering by userId (Firebase UID)
    if (userId) {
      const user = await User.findOne({ firebaseUid: userId });
      if (user) {
        query.userId = user._id;
      } else {
        // User not found in MongoDB, return empty array
        return res.status(200).json({
          success: true,
          count: 0,
          total: 0,
          page: parseInt(page),
          pages: 0,
          data: []
        });
      }
    }

    const helpRequests = await HelpRequest.find(query)
      .populate('userId', 'username email profileImage karma firebaseUid')
      .populate('helperId', 'username email profileImage firebaseUid')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit));

    const total = await HelpRequest.countDocuments(query);

    res.status(200).json({
      success: true,
      count: helpRequests.length,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / parseInt(limit)),
      data: helpRequests
    });
  } catch (error) {
    console.error('Error in getAllHelpRequests:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get help requests'
    });
  }
};

// Get help request by ID
export const getHelpRequestById = async (req, res) => {
  try {
    const { id } = req.params;

    const helpRequest = await HelpRequest.findById(id)
      .populate('userId', 'username email profileImage karma')
      .populate('helperId', 'username email profileImage');

    if (!helpRequest) {
      return res.status(404).json({
        success: false,
        message: 'Help request not found'
      });
    }

    // Increment views
    helpRequest.views += 1;
    await helpRequest.save();

    res.status(200).json({
      success: true,
      data: helpRequest
    });
  } catch (error) {
    console.error('Error in getHelpRequestById:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get help request'
    });
  }
};

// Accept help request (volunteer to help)
export const acceptHelpRequest = async (req, res) => {
  try {
    const { id } = req.params;
    const { firebaseUid } = req.body;

    const helper = await User.findOne({ firebaseUid });
    if (!helper) {
      return res.status(404).json({
        success: false,
        message: 'Helper user not found'
      });
    }

    const helpRequest = await HelpRequest.findById(id);
    if (!helpRequest) {
      return res.status(404).json({
        success: false,
        message: 'Help request not found'
      });
    }

    if (helpRequest.status !== 'Open') {
      return res.status(400).json({
        success: false,
        message: 'Help request is not available'
      });
    }

    helpRequest.helperId = helper._id;
    helpRequest.status = 'InProgress';
    helpRequest.helperAcceptedAt = Date.now();
    await helpRequest.save();

    // Award +10 karma points for accepting/offering help
    await User.findByIdAndUpdate(helper._id, {
      $inc: { karma: 10 }
    });

    // Get requester info to send notification
    const requester = await User.findById(helpRequest.userId);
    if (requester && requester.firebaseUid) {
      sendNotificationToUser(
        requester.firebaseUid,
        '✅ Help Request Accepted!',
        `${helper.username || 'Someone'} accepted your request: ${helpRequest.title}`,
        {
          type: 'request_accepted',
          requestId: helpRequest._id.toString(),
          helperId: helper._id.toString()
        }
      ).catch(err => console.error('Notification error:', err));
    }

    res.status(200).json({
      success: true,
      message: 'Help request accepted successfully',
      data: helpRequest
    });
  } catch (error) {
    console.error('Error in acceptHelpRequest:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to accept help request'
    });
  }
};

// Complete help request
export const completeHelpRequest = async (req, res) => {
  try {
    const { id } = req.params;

    const helpRequest = await HelpRequest.findById(id);
    if (!helpRequest) {
      return res.status(404).json({
        success: false,
        message: 'Help request not found'
      });
    }

    helpRequest.status = 'Completed';
    helpRequest.completedAt = Date.now();
    await helpRequest.save();

    // Award +20 karma points to helper for completing the help request
    if (helpRequest.helperId) {
      await User.findByIdAndUpdate(helpRequest.helperId, {
        $inc: { 
          karma: 20,  // +20 points for completing help request
          helpRequestsFulfilled: 1
        }
      });

      // Send notification to helper about karma reward
      const helper = await User.findById(helpRequest.helperId);
      if (helper && helper.firebaseUid) {
        sendNotificationToUser(
          helper.firebaseUid,
          '🎉 Help Request Completed!',
          `You earned +20 karma for completing: ${helpRequest.title}`,
          {
            type: 'request_completed',
            requestId: helpRequest._id.toString(),
            karmaEarned: 20
          }
        ).catch(err => console.error('Notification error:', err));
      }
    }

    res.status(200).json({
      success: true,
      message: 'Help request completed successfully',
      data: helpRequest
    });
  } catch (error) {
    console.error('Error in completeHelpRequest:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to complete help request'
    });
  }
};

// Get nearby help requests (using geospatial query)
export const getNearbyHelpRequests = async (req, res) => {
  try {
    const { longitude, latitude, maxDistance = 5000 } = req.query; // maxDistance in meters

    if (!longitude || !latitude) {
      return res.status(400).json({
        success: false,
        message: 'Longitude and latitude are required'
      });
    }

    const helpRequests = await HelpRequest.find({
      status: 'Open',
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(longitude), parseFloat(latitude)]
          },
          $maxDistance: parseInt(maxDistance)
        }
      }
    })
      .populate('userId', 'username email profileImage karma')
      .limit(20);

    res.status(200).json({
      success: true,
      count: helpRequests.length,
      data: helpRequests
    });
  } catch (error) {
    console.error('Error in getNearbyHelpRequests:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get nearby help requests'
    });
  }
};

// Update help request
export const updateHelpRequest = async (req, res) => {
  try {
    const { id } = req.params;
    const { firebaseUid, title, description, category, urgency, location, images } = req.body;

    // Find the help request
    const helpRequest = await HelpRequest.findById(id);
    if (!helpRequest) {
      return res.status(404).json({
        success: false,
        message: 'Help request not found'
      });
    }

    // Verify the user owns this request
    const user = await User.findOne({ firebaseUid });
    if (!user || helpRequest.userId.toString() !== user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You can only edit your own help requests'
      });
    }

    // Update fields
    if (title) helpRequest.title = title;
    if (description) helpRequest.description = description;
    if (category) helpRequest.category = category;
    if (urgency) helpRequest.urgency = urgency;
    if (location) helpRequest.location = location;
    if (images) helpRequest.images = images;

    await helpRequest.save();

    res.status(200).json({
      success: true,
      message: 'Help request updated successfully',
      data: helpRequest
    });
  } catch (error) {
    console.error('Error in updateHelpRequest:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to update help request'
    });
  }
};

// Delete help request
export const deleteHelpRequest = async (req, res) => {
  try {
    const { id } = req.params;
    const { firebaseUid } = req.query;

    // Find the help request
    const helpRequest = await HelpRequest.findById(id);
    if (!helpRequest) {
      return res.status(404).json({
        success: false,
        message: 'Help request not found'
      });
    }

    // Verify the user owns this request
    const user = await User.findOne({ firebaseUid });
    if (!user || helpRequest.userId.toString() !== user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own help requests'
      });
    }

    await HelpRequest.findByIdAndDelete(id);

    // Update user's help requests count
    await User.findByIdAndUpdate(user._id, {
      $inc: { helpRequestsCreated: -1 }
    });

    res.status(200).json({
      success: true,
      message: 'Help request deleted successfully'
    });
  } catch (error) {
    console.error('Error in deleteHelpRequest:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to delete help request'
    });
  }
};

