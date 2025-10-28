import mongoose from 'mongoose';

const donationSchema = new mongoose.Schema({
  userId: {
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
    enum: ['Books', 'Clothes', 'Electronics', 'Furniture', 'Food', 'Other']
  },
  images: [{
    type: String
  }],
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
  status: {
    type: String,
    enum: ['Available', 'Reserved', 'Donated'],
    default: 'Available'
  },
  recipientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  karmaAwarded: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

donationSchema.index({ userId: 1 });
donationSchema.index({ status: 1 });

const Donation = mongoose.model('Donation', donationSchema);

export default Donation;
