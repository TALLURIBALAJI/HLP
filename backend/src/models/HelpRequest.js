import mongoose from 'mongoose';

const helpRequestSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
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
    enum: ['Academic', 'Technical', 'Personal', 'Transport', 'Food', 'Other']
  },
  urgency: {
    type: String,
    enum: ['Low', 'Medium', 'High'],
    default: 'Medium'
  },
  status: {
    type: String,
    enum: ['Open', 'InProgress', 'Completed', 'Cancelled'],
    default: 'Open'
  },
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      default: [0, 0]
    },
    address: String
  },
  images: [{
    type: String // URLs to images
  }],
  helperId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  helperAcceptedAt: {
    type: Date,
    default: null
  },
  completedAt: {
    type: Date,
    default: null
  },
  karmaPoints: {
    type: Number,
    default: 2  // +2 points for creating a help request
  },
  views: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

// Geospatial index for location-based queries
helpRequestSchema.index({ location: '2dsphere' });
helpRequestSchema.index({ status: 1, createdAt: -1 });

const HelpRequest = mongoose.model('HelpRequest', helpRequestSchema);

export default HelpRequest;
