import Event from '../models/Event.js';
import User from '../models/User.js';
import { sendNotificationExceptUser, sendNotificationToUser } from '../services/notificationService.js';

// Create event
export const createEvent = async (req, res) => {
  try {
    const { firebaseUid, title, description, category, eventDate, location, volunteersNeeded, images } = req.body;

    const user = await User.findOne({ firebaseUid });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const event = await Event.create({
      organizerId: user._id,
      title,
      description,
      category,
      eventDate,
      location,
      volunteersNeeded: volunteersNeeded || 1,
      images: images || []
    });

    // Send notification to all users
    sendNotificationExceptUser(
      firebaseUid,
      '📅 New Event',
      `${title} - ${category}`,
      {
        type: 'new_event',
        eventId: event._id.toString(),
        category
      }
    ).catch(err => console.error('Notification error:', err));

    res.status(201).json({
      success: true,
      message: 'Event created successfully',
      data: event
    });
  } catch (error) {
    console.error('Error in createEvent:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to create event'
    });
  }
};

// Get all events
export const getAllEvents = async (req, res) => {
  try {
    const { status, category, limit = 50, page = 1 } = req.query;

    const query = {};
    if (status) query.status = status;
    if (category) query.category = category;

    const events = await Event.find(query)
      .populate('organizerId', 'username email profileImage firebaseUid')
      .populate('volunteers.userId', 'username email profileImage')
      .sort({ eventDate: 1 })
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit));

    const total = await Event.countDocuments(query);

    res.status(200).json({
      success: true,
      count: events.length,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / parseInt(limit)),
      data: events
    });
  } catch (error) {
    console.error('Error in getAllEvents:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get events'
    });
  }
};

// Register as volunteer
export const registerVolunteer = async (req, res) => {
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

    const event = await Event.findById(id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found'
      });
    }

    // Check if already registered
    const alreadyRegistered = event.volunteers.some(
      v => v.userId.toString() === user._id.toString()
    );

    if (alreadyRegistered) {
      return res.status(400).json({
        success: false,
        message: 'You are already registered for this event'
      });
    }

    // Add volunteer
    event.volunteers.push({
      userId: user._id,
      registeredAt: Date.now()
    });
    await event.save();

    // Notify organizer
    const organizer = await User.findById(event.organizerId);
    if (organizer && organizer.firebaseUid) {
      sendNotificationToUser(
        organizer.firebaseUid,
        '👥 New Volunteer',
        `${user.username} registered for your event: ${event.title}`,
        {
          type: 'volunteer_registered',
          eventId: event._id.toString()
        }
      ).catch(err => console.error('Notification error:', err));
    }

    res.status(200).json({
      success: true,
      message: 'Registered as volunteer successfully',
      data: event
    });
  } catch (error) {
    console.error('Error in registerVolunteer:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to register as volunteer'
    });
  }
};

// Mark volunteer as attended and award karma
export const markAttendance = async (req, res) => {
  try {
    const { id } = req.params;
    const { volunteerId } = req.body;

    const event = await Event.findById(id);
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Event not found'
      });
    }

    // Find volunteer in the event
    const volunteer = event.volunteers.find(
      v => v.userId.toString() === volunteerId
    );

    if (!volunteer) {
      return res.status(404).json({
        success: false,
        message: 'Volunteer not found in this event'
      });
    }

    // Mark as attended
    volunteer.attended = true;

    // Award +25 karma points if not already awarded
    if (!volunteer.karmaAwarded) {
      await User.findByIdAndUpdate(volunteerId, {
        $inc: { karma: 25 }
      });
      volunteer.karmaAwarded = true;

      // Notify volunteer
      const user = await User.findById(volunteerId);
      if (user && user.firebaseUid) {
        sendNotificationToUser(
          user.firebaseUid,
          '🎉 Volunteering Karma Earned!',
          `You earned +25 karma for volunteering at: ${event.title}`,
          {
            type: 'karma_earned',
            karmaEarned: 25,
            eventId: event._id.toString()
          }
        ).catch(err => console.error('Notification error:', err));
      }
    }

    await event.save();

    res.status(200).json({
      success: true,
      message: 'Attendance marked and karma awarded',
      data: event
    });
  } catch (error) {
    console.error('Error in markAttendance:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to mark attendance'
    });
  }
};
