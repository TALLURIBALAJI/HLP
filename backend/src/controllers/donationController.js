import Donation from '../models/Donation.js';
import User from '../models/User.js';
import { sendNotificationExceptUser, sendNotificationToUser } from '../services/notificationService.js';

// Create donation
export const createDonation = async (req, res) => {
  try {
    const { firebaseUid, title, description, category, location, images } = req.body;

    const user = await User.findOne({ firebaseUid });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const donation = await Donation.create({
      userId: user._id,
      title,
      description,
      category,
      location,
      images: images || []
    });

    // Award +15 karma points for donating
    await User.findByIdAndUpdate(user._id, {
      $inc: { karma: 15 }
    });

    // Mark donation as karma awarded
    donation.karmaAwarded = true;
    await donation.save();

    // Send notification to all users
    sendNotificationExceptUser(
      firebaseUid,
      '🎁 New Donation Available',
      `${title} - ${category}`,
      {
        type: 'new_donation',
        donationId: donation._id.toString(),
        category
      }
    ).catch(err => console.error('Notification error:', err));

    res.status(201).json({
      success: true,
      message: 'Donation created successfully and earned +15 karma!',
      data: donation
    });
  } catch (error) {
    console.error('Error in createDonation:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to create donation'
    });
  }
};

// Get all donations
export const getAllDonations = async (req, res) => {
  try {
    const { status, category, limit = 50, page = 1 } = req.query;

    const query = {};
    if (status) query.status = status;
    if (category) query.category = category;

    const donations = await Donation.find(query)
      .populate('userId', 'username email profileImage firebaseUid')
      .populate('recipientId', 'username email profileImage')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit));

    const total = await Donation.countDocuments(query);

    res.status(200).json({
      success: true,
      count: donations.length,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / parseInt(limit)),
      data: donations
    });
  } catch (error) {
    console.error('Error in getAllDonations:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get donations'
    });
  }
};

// Claim a donation
export const claimDonation = async (req, res) => {
  try {
    const { id } = req.params;
    const { firebaseUid } = req.body;

    const user = await User.findOne({ firebaseUid });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const donation = await Donation.findById(id);
    if (!donation) {
      return res.status(404).json({
        success: false,
        message: 'Donation not found'
      });
    }

    if (donation.status !== 'Available') {
      return res.status(400).json({
        success: false,
        message: 'Donation is not available'
      });
    }

    donation.status = 'Reserved';
    donation.recipientId = user._id;
    await donation.save();

    // Notify donor
    const donor = await User.findById(donation.userId);
    if (donor && donor.firebaseUid) {
      sendNotificationToUser(
        donor.firebaseUid,
        '✅ Donation Claimed',
        `${user.username} claimed your donation: ${donation.title}`,
        {
          type: 'donation_claimed',
          donationId: donation._id.toString()
        }
      ).catch(err => console.error('Notification error:', err));
    }

    res.status(200).json({
      success: true,
      message: 'Donation claimed successfully',
      data: donation
    });
  } catch (error) {
    console.error('Error in claimDonation:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to claim donation'
    });
  }
};

// Mark donation as completed
export const completeDonation = async (req, res) => {
  try {
    const { id } = req.params;

    const donation = await Donation.findById(id);
    if (!donation) {
      return res.status(404).json({
        success: false,
        message: 'Donation not found'
      });
    }

    donation.status = 'Donated';
    await donation.save();

    res.status(200).json({
      success: true,
      message: 'Donation marked as completed',
      data: donation
    });
  } catch (error) {
    console.error('Error in completeDonation:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to complete donation'
    });
  }
};
