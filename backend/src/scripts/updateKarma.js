import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from '../models/User.js';
import HelpRequest from '../models/HelpRequest.js';

// Load environment variables
dotenv.config({ path: './backend/.env' });

// Script to update karma for existing users based on their posts
async function updateUserKarma() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');
    console.log('📊 Starting karma update for existing users...');

    // Get all users
    const users = await User.find({});
    console.log(`Found ${users.length} users`);

    for (const user of users) {
      // Count posts created by this user
      const postsCount = await HelpRequest.countDocuments({ userId: user._id });
      
      // Calculate karma: +2 points per post created
      const karmaFromPosts = postsCount * 2;
      
      // Count completed help requests where this user was the helper
      const helpedCount = await HelpRequest.countDocuments({ 
        helperId: user._id, 
        status: 'Completed' 
      });
      
      // Calculate karma: +10 for accepting + +20 for completing = +30 per completed help
      const karmaFromHelping = helpedCount * 30;
      
      const totalKarma = karmaFromPosts + karmaFromHelping;
      
      // Update user
      await User.findByIdAndUpdate(user._id, {
        karma: totalKarma,
        helpRequestsCreated: postsCount,
        helpRequestsFulfilled: helpedCount
      });
      
      console.log(`✅ Updated ${user.username}: ${postsCount} posts, ${helpedCount} helps → ${totalKarma} karma`);
    }

    console.log('🎉 Karma update completed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error updating karma:', error);
    process.exit(1);
  }
}

updateUserKarma();
