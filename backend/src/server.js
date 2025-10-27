import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import connectDB from './config/database.js';
import userRoutes from './routes/userRoutes.js';
import helpRequestRoutes from './routes/helpRequestRoutes.js';
import uploadRoutes from './routes/uploadRoutes.js';
import chatRoutes from './routes/chatRoutes.js';

// Load environment variables
dotenv.config();

// Initialize Express app
const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: "*", // Allow all origins for Flutter app
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 3000;

// Connect to MongoDB
connectDB();

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS for Flutter app
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

// Routes
app.get('/', (req, res) => {
  res.json({
    message: '🚀 HelpLink API Server',
    version: '1.0.0',
    status: 'running'
  });
});

app.use('/api/users', userRoutes);
app.use('/api/help-requests', helpRequestRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/chats', chatRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error Handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error'
  });
});

// Socket.io connection handling
io.on('connection', (socket) => {
  console.log(`✅ User connected: ${socket.id}`);

  // Join a chat room
  socket.on('join_chat', (chatId) => {
    socket.join(chatId);
    console.log(`👤 User ${socket.id} joined chat: ${chatId}`);
  });

  // Send message
  socket.on('send_message', (data) => {
    const { chatId, message } = data;
    // Broadcast to all users in the chat room
    io.to(chatId).emit('receive_message', message);
    console.log(`💬 Message sent to chat ${chatId}`);
  });

  // Leave chat room
  socket.on('leave_chat', (chatId) => {
    socket.leave(chatId);
    console.log(`👋 User ${socket.id} left chat: ${chatId}`);
  });

  // Handle disconnection
  socket.on('disconnect', () => {
    console.log(`❌ User disconnected: ${socket.id}`);
  });
});

// Make io accessible to routes
app.set('socketio', io);

// Start server - bind to 0.0.0.0 to accept connections from Android emulator
httpServer.listen(PORT, '0.0.0.0', () => {
  console.log(`\n🚀 Server running on port ${PORT}`);
  console.log(`📍 http://localhost:${PORT}`);
  console.log(`📱 For Android Emulator: http://10.0.2.2:${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`💬 Socket.io enabled for real-time chat\n`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('❌ Unhandled Promise Rejection:', err);
  process.exit(1);
});
