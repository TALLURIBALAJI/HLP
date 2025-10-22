// models/User.js
import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  phone: { type: String },
  avatarUrl: { type: String },
  karma: { type: Number, default: 0 },
  level: { type: Number, default: 1 },
  badges: [{ type: String }],
  // optional last known location [lng, lat]
  location: {
    type: { type: String, enum: ['Point'], default: 'Point' },
    coordinates: { type: [Number], default: [0, 0] } // [lng, lat]
  }
}, { timestamps: true });

// 2dsphere index helps geo-queries later
userSchema.index({ location: '2dsphere' });

const User = mongoose.models.User || mongoose.model('User', userSchema);
export default User;
