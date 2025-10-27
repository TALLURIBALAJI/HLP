import express from 'express';
import * as chatController from '../controllers/chatController.js';

const router = express.Router();

// Create or get existing chat
router.post('/', chatController.createOrGetChat);

// Get messages for a chat
router.get('/:chatId/messages', chatController.getMessages);

// Send a message
router.post('/:chatId/messages', chatController.sendMessage);

// Get all chats for a user
router.get('/user/:userId', chatController.getUserChats);

export default router;
