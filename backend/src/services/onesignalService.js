import * as OneSignal from '@onesignal/node-onesignal';
import dotenv from 'dotenv';

dotenv.config();

// Initialize OneSignal Client
const app_key_provider = {
  getToken() {
    return process.env.ONESIGNAL_REST_API_KEY;
  }
};

const configuration = OneSignal.createConfiguration({
  authMethods: {
    app_key: {
      tokenProvider: app_key_provider
    }
  }
});

const client = new OneSignal.DefaultApi(configuration);

/**
 * Send notification to specific user by Firebase UID
 */
export const sendNotificationToUser = async (firebaseUid, title, message, data = {}) => {
  try {
    const notification = new OneSignal.Notification();
    notification.app_id = process.env.ONESIGNAL_APP_ID;
    
    // Target specific user by External User ID (Firebase UID)
    notification.include_external_user_ids = [firebaseUid];
    
    // Notification content
    notification.headings = { en: title };
    notification.contents = { en: message };
    
    // Additional data to pass to app
    notification.data = data;
    
    // Send notification
    const response = await client.createNotification(notification);
    console.log('✅ Notification sent to user:', firebaseUid);
    return response;
  } catch (error) {
    console.error('❌ Error sending notification:', error);
    throw error;
  }
};

/**
 * Send notification to all users
 */
export const sendNotificationToAll = async (title, message, data = {}) => {
  try {
    const notification = new OneSignal.Notification();
    notification.app_id = process.env.ONESIGNAL_APP_ID;
    
    // Send to all subscribed users
    notification.included_segments = ['All'];
    
    // Notification content
    notification.headings = { en: title };
    notification.contents = { en: message };
    
    // Additional data
    notification.data = data;
    
    // Send notification
    const response = await client.createNotification(notification);
    console.log('✅ Notification sent to all users');
    return response;
  } catch (error) {
    console.error('❌ Error sending notification to all:', error);
    throw error;
  }
};

/**
 * Send notification to multiple specific users
 */
export const sendNotificationToUsers = async (firebaseUids, title, message, data = {}) => {
  try {
    const notification = new OneSignal.Notification();
    notification.app_id = process.env.ONESIGNAL_APP_ID;
    
    // Target multiple users
    notification.include_external_user_ids = firebaseUids;
    
    // Notification content
    notification.headings = { en: title };
    notification.contents = { en: message };
    
    // Additional data
    notification.data = data;
    
    // Send notification
    const response = await client.createNotification(notification);
    console.log(`✅ Notification sent to ${firebaseUids.length} users`);
    return response;
  } catch (error) {
    console.error('❌ Error sending notifications:', error);
    throw error;
  }
};

/**
 * Send notification for new help request
 */
export const notifyNewHelpRequest = async (excludeUserId, requestData) => {
  try {
    // TODO: Get all user Firebase UIDs except the creator
    // For now, send to all users
    await sendNotificationToAll(
      '🆘 New Help Request',
      `${requestData.title} - ${requestData.category}`,
      {
        type: 'new_help_request',
        requestId: requestData._id.toString(),
        category: requestData.category
      }
    );
  } catch (error) {
    console.error('❌ Error sending new help request notification:', error);
  }
};

/**
 * Send notification when request is accepted
 */
export const notifyRequestAccepted = async (requesterFirebaseUid, helperName, requestTitle) => {
  try {
    await sendNotificationToUser(
      requesterFirebaseUid,
      '✅ Request Accepted!',
      `${helperName} accepted your request: "${requestTitle}"`,
      {
        type: 'request_accepted',
        karmaEarned: 10
      }
    );
  } catch (error) {
    console.error('❌ Error sending request accepted notification:', error);
  }
};

/**
 * Send notification when request is completed
 */
export const notifyRequestCompleted = async (helperFirebaseUid, requestTitle) => {
  try {
    await sendNotificationToUser(
      helperFirebaseUid,
      '🎉 Request Completed!',
      `You earned +20 karma for completing: "${requestTitle}"`,
      {
        type: 'request_completed',
        karmaEarned: 20
      }
    );
  } catch (error) {
    console.error('❌ Error sending request completed notification:', error);
  }
};

/**
 * Send notification for new message
 */
export const notifyNewMessage = async (recipientFirebaseUid, senderName, messagePreview) => {
  try {
    await sendNotificationToUser(
      recipientFirebaseUid,
      '💬 New Message',
      `${senderName}: ${messagePreview}`,
      {
        type: 'new_message',
        senderName
      }
    );
  } catch (error) {
    console.error('❌ Error sending new message notification:', error);
  }
};

export default {
  sendNotificationToUser,
  sendNotificationToAll,
  sendNotificationToUsers,
  notifyNewHelpRequest,
  notifyRequestAccepted,
  notifyRequestCompleted,
  notifyNewMessage
};
