import mongoose from 'mongoose';

const reportSchema = new mongoose.Schema({
  reporterId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  reportedContentType: {
    type: String,
    required: true,
    enum: ['HelpRequest', 'User', 'Donation', 'Event']
  },
  reportedContentId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true
  },
  reason: {
    type: String,
    required: true,
    enum: ['Spam', 'Fake', 'Inappropriate', 'Scam', 'Other']
  },
  description: {
    type: String,
    trim: true
  },
  status: {
    type: String,
    enum: ['Pending', 'Reviewing', 'Verified', 'Rejected'],
    default: 'Pending'
  },
  karmaAwarded: {
    type: Boolean,
    default: false
  },
  reviewedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  reviewedAt: {
    type: Date,
    default: null
  }
}, {
  timestamps: true
});

reportSchema.index({ reporterId: 1 });
reportSchema.index({ status: 1 });
reportSchema.index({ reportedContentId: 1 });

const Report = mongoose.model('Report', reportSchema);

export default Report;
