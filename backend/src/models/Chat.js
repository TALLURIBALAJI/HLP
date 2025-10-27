import mongoose from 'mongoose';

const messageSchema = new mongoose.Schema({
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  message: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const chatSchema = new mongoose.Schema({
  participants: [{
    type: String, // Firebase UIDs
    required: true
  }],
  messages: [messageSchema],
  lastMessage: {
    type: String
  },
  lastMessageTime: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Create index for faster lookups
chatSchema.index({ participants: 1 });

export default mongoose.model('Chat', chatSchema);
