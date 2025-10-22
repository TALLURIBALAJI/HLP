import express from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import usersRouter from './routes/users.js';
// import postsRouter from './routes/posts.js'; // if you already have posts route

dotenv.config();

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI;

// connect to MongoDB
mongoose.connect(MONGO_URI)
  .then(() => console.log('✅ MongoDB connected successfully!'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// test root
app.get('/', (req, res) => res.send('HelpLink backend is running'));

// use routes
app.use('/api/users', usersRouter);

// if posts route exists, enable it
// app.use('/api/posts', postsRouter);

app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
