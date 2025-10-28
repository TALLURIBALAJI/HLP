import mongoose from 'mongoose';

const eventSchema = new mongoose.Schema({
  organizerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true
  },
  category: {
    type: String,
    required: true,
    enum: ['Community Service', 'Education', 'Environment', 'Health', 'Social', 'Other']
  },
  eventDate: {
    type: Date,
    required: true
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number],
      default: [0, 0]
    },
    address: String
  },
  volunteersNeeded: {
    type: Number,
    default: 1
  },
  volunteers: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    registeredAt: {
      type: Date,
      default: Date.now
    },
    attended: {
      type: Boolean,
      default: false
    },
    karmaAwarded: {
      type: Boolean,
      default: false
    }
  }],
  images: [{
    type: String
  }],
  status: {
    type: String,
    enum: ['Upcoming', 'Ongoing', 'Completed', 'Cancelled'],
    default: 'Upcoming'
  }
}, {
  timestamps: true
});

eventSchema.index({ organizerId: 1 });
eventSchema.index({ eventDate: 1 });
eventSchema.index({ status: 1 });

const Event = mongoose.model('Event', eventSchema);

export default Event;
