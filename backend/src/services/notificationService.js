import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load .env from backend directory (parent of src)
dotenv.config({ path: join(__dirname, '../../.env') });

const ONESIGNAL_APP_ID = process.env.ONESIGNAL_APP_ID;
const ONESIGNAL_REST_API_KEY = process.env.ONESIGNAL_REST_API_KEY;

// Debug: Check if credentials are loaded
if (!ONESIGNAL_APP_ID || !ONESIGNAL_REST_API_KEY) {
  console.warn('⚠️ OneSignal credentials not found in environment variables!');
  console.warn('   ONESIGNAL_APP_ID:', ONESIGNAL_APP_ID ? '✓ Set' : '✗ Missing');
  console.warn('   ONESIGNAL_REST_API_KEY:', ONESIGNAL_REST_API_KEY ? '✓ Set' : '✗ Missing');
} else {
  console.log('✅ OneSignal credentials loaded successfully');
}

/**
 * Send notification to all users
 * @param {string} title - Notification title
 * @param {string} message - Notification message
 * @param {object} data - Additional data to send with notification
 */
export const sendNotificationToAll = async (title, message, data = {}) => {
  try {
    const response = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`
      },
      body: JSON.stringify({
        app_id: ONESIGNAL_APP_ID,
        headings: { en: title },
        contents: { en: message },
        data: data,
        included_segments: ['All']
      })
    });

    const result = await response.json();
    
    if (!response.ok) {
      console.error('❌ OneSignal API Error:', result);
      throw new Error(`OneSignal Error: ${result.errors || 'Unknown error'}`);
    }

    console.log('✅ Notification sent to all users:', result);
    return result;
  } catch (error) {
    console.error('❌ Error sending notification to all:', error);
    throw error;
  }
};

/**
 * Send notification to a specific user by Firebase UID
 * @param {string} firebaseUid - Firebase user ID
 * @param {string} title - Notification title
 * @param {string} message - Notification message
 * @param {object} data - Additional data to send with notification
 */
export const sendNotificationToUser = async (firebaseUid, title, message, data = {}) => {
  try {
    const response = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`
      },
      body: JSON.stringify({
        app_id: ONESIGNAL_APP_ID,
        headings: { en: title },
        contents: { en: message },
        data: data,
        include_external_user_ids: [firebaseUid]
      })
    });

    const result = await response.json();
    
    if (!response.ok) {
      console.error('❌ OneSignal API Error:', result);
      throw new Error(`OneSignal Error: ${result.errors || 'Unknown error'}`);
    }

    console.log(`✅ Notification sent to user ${firebaseUid}:`, result);
    return result;
  } catch (error) {
    console.error(`❌ Error sending notification to user ${firebaseUid}:`, error);
    throw error;
  }
};

/**
 * Send notification to multiple users
 * @param {string[]} firebaseUids - Array of Firebase user IDs
 * @param {string} title - Notification title
 * @param {string} message - Notification message
 * @param {object} data - Additional data to send with notification
 */
export const sendNotificationToUsers = async (firebaseUids, title, message, data = {}) => {
  try {
    const response = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`
      },
      body: JSON.stringify({
        app_id: ONESIGNAL_APP_ID,
        headings: { en: title },
        contents: { en: message },
        data: data,
        include_external_user_ids: firebaseUids
      })
    });

    const result = await response.json();
    
    if (!response.ok) {
      console.error('❌ OneSignal API Error:', result);
      throw new Error(`OneSignal Error: ${result.errors || 'Unknown error'}`);
    }

    console.log(`✅ Notification sent to ${firebaseUids.length} users:`, result);
    return result;
  } catch (error) {
    console.error('❌ Error sending notification to users:', error);
    throw error;
  }
};

/**
 * Send notification to all users except one (useful when someone posts)
 * @param {string} excludeFirebaseUid - Firebase UID to exclude
 * @param {string} title - Notification title
 * @param {string} message - Notification message
 * @param {object} data - Additional data
 */
export const sendNotificationExceptUser = async (excludeFirebaseUid, title, message, data = {}) => {
  try {
    // Send to ALL users (not just subscribed)
    const response = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`
      },
      body: JSON.stringify({
        app_id: ONESIGNAL_APP_ID,
        headings: { en: title },
        contents: { en: message },
        data: data,
        included_segments: ['All'], // Send to ALL users
      })
    });

    const result = await response.json();
    
    if (!response.ok) {
      console.error('❌ OneSignal API Error:', result);
      throw new Error(`OneSignal Error: ${JSON.stringify(result.errors) || 'Unknown error'}`);
    }

    console.log(`✅ Notification sent to all users:`, result);
    return result;
  } catch (error) {
    console.error('❌ Error sending notification except user:', error);
    throw error;
  }
};
