import mongoose from 'mongoose';

const feedbackSchema = new mongoose.Schema({
  helpRequestId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'HelpRequest',
    required: true
  },
  fromUserId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  toUserId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  rating: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },
  comment: {
    type: String,
    trim: true
  }
}, {
  timestamps: true
});

// Index for faster queries
feedbackSchema.index({ helpRequestId: 1 });
feedbackSchema.index({ toUserId: 1 });

const Feedback = mongoose.model('Feedback', feedbackSchema);

export default Feedback;
