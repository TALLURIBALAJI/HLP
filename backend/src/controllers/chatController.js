import Chat from '../models/Chat.js';
import User from '../models/User.js';

// Create or get existing chat between two users
export const createOrGetChat = async (req, res) => {
  try {
    const { user1Id, user2Id } = req.body;

    if (!user1Id || !user2Id) {
      return res.status(400).json({ message: 'Both user IDs are required' });
    }

    // Sort IDs to ensure consistent chat lookup
    const participants = [user1Id, user2Id].sort();

    // Check if chat already exists
    let chat = await Chat.findOne({
      participants: { $all: participants, $size: 2 }
    }).populate('messages.sender', 'username email firebaseUid profileImage');

    if (!chat) {
      // Create new chat
      chat = new Chat({
        participants,
        messages: []
      });
      await chat.save();
    }

    res.status(200).json({ chat });
  } catch (error) {
    console.error('Error in createOrGetChat:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Get all messages for a chat
export const getMessages = async (req, res) => {
  try {
    const { chatId } = req.params;

    const chat = await Chat.findById(chatId)
      .populate('messages.sender', 'username email firebaseUid profileImage');

    if (!chat) {
      return res.status(404).json({ message: 'Chat not found' });
    }

    res.status(200).json({ messages: chat.messages });
  } catch (error) {
    console.error('Error in getMessages:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Send a message
export const sendMessage = async (req, res) => {
  try {
    const { chatId } = req.params;
    const { senderId, message } = req.body;

    if (!message || !senderId) {
      return res.status(400).json({ message: 'Sender ID and message are required' });
    }

    // Find the user by Firebase UID
    const user = await User.findOne({ firebaseUid: senderId });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Find the chat
    const chat = await Chat.findById(chatId);
    if (!chat) {
      return res.status(404).json({ message: 'Chat not found' });
    }

    // Add message
    chat.messages.push({
      sender: user._id,
      message: message
    });

    chat.lastMessage = message;
    chat.lastMessageTime = new Date();

    await chat.save();

    // Populate sender info for response
    const populatedChat = await Chat.findById(chatId)
      .populate('messages.sender', 'username email firebaseUid profileImage');

    const newMessage = populatedChat.messages[populatedChat.messages.length - 1];

    res.status(201).json({ 
      message: 'Message sent successfully',
      messageData: newMessage 
    });
  } catch (error) {
    console.error('Error in sendMessage:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Get all chats for a user
export const getUserChats = async (req, res) => {
  try {
    const { userId } = req.params;

    const chats = await Chat.find({
      participants: userId
    })
    .populate('messages.sender', 'username email firebaseUid profileImage')
    .sort({ lastMessageTime: -1 });

    // For each chat, get the other participant's info
    const chatsWithParticipants = await Promise.all(
      chats.map(async (chat) => {
        const otherParticipantId = chat.participants.find(p => p !== userId);
        const otherParticipant = await User.findOne({ firebaseUid: otherParticipantId });

        return {
          ...chat.toObject(),
          otherParticipant: otherParticipant ? {
            username: otherParticipant.username,
            email: otherParticipant.email,
            firebaseUid: otherParticipant.firebaseUid,
            profileImage: otherParticipant.profileImage
          } : null
        };
      })
    );

    res.status(200).json({ chats: chatsWithParticipants });
  } catch (error) {
    console.error('Error in getUserChats:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};
