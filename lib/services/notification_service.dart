import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  // ⚠️ REPLACE WITH YOUR ONESIGNAL APP ID
  // Get this from: https://app.onesignal.com/apps
  static const String _oneSignalAppId = '1fc86ca5-670b-48cd-960e-5e2c54bb14c2';
  
  /// Initialize OneSignal
  static Future<void> initialize() async {
    try {
      print('🔔 Initializing OneSignal...');
      
      // Initialize OneSignal with your App ID
      OneSignal.initialize(_oneSignalAppId);
      
      // Request notification permission (iOS 13+, Android 13+)
      await OneSignal.Notifications.requestPermission(true);
      
      // Set up notification handlers
      _setupNotificationHandlers();
      
      print('✅ OneSignal initialized successfully!');
      
      // Print Player ID (useful for testing)
      final playerId = OneSignal.User.pushSubscription.id;
      print('📱 OneSignal Player ID: $playerId');
    } catch (e) {
      print('❌ OneSignal initialization error: $e');
    }
  }
  
  /// Setup notification event handlers
  static void _setupNotificationHandlers() {
    // Called when notification is received while app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print('🔔 Notification received in foreground: ${event.notification.title}');
      
      // You can prevent the notification from displaying
      // event.preventDefault();
      
      // Or show it
      event.notification.display();
    });
    
    // Called when user opens a notification
    OneSignal.Notifications.addClickListener((event) {
      print('🔔 Notification clicked: ${event.notification.title}');
      
      // Handle notification click
      final data = event.notification.additionalData;
      if (data != null) {
        _handleNotificationClick(data);
      }
    });
    
    // Called when permission state changes
    OneSignal.Notifications.addPermissionObserver((state) {
      print('🔔 Notification permission changed: $state');
    });
  }
  
  /// Handle notification click based on data
  static void _handleNotificationClick(Map<String, dynamic> data) {
    print('🔔 Notification data: $data');
    
    // Example: Navigate to specific screen based on notification type
    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'new_help_request':
          print('Navigate to: Home Feed');
          // TODO: Use Navigator to go to home feed
          break;
        case 'request_accepted':
          print('Navigate to: My Posts');
          // TODO: Use Navigator to go to user's posts
          break;
        case 'request_completed':
          print('Navigate to: Profile (karma updated)');
          // TODO: Use Navigator to go to profile
          break;
        case 'new_message':
          print('Navigate to: Chat');
          // TODO: Use Navigator to go to chat
          break;
        default:
          print('Unknown notification type');
      }
    }
  }
  
  /// Get the OneSignal Player ID (for targeting specific users)
  static Future<String?> getPlayerId() async {
    try {
      // Wait a bit for OneSignal to fully initialize
      await Future.delayed(const Duration(milliseconds: 500));
      return OneSignal.User.pushSubscription.id;
    } catch (e) {
      print('❌ Error getting Player ID: $e');
      return null;
    }
  }
  
  /// Set external user ID (link OneSignal with Firebase UID)
  static Future<void> setExternalUserId(String firebaseUid) async {
    try {
      await OneSignal.login(firebaseUid);
      print('✅ OneSignal external user ID set: $firebaseUid');
      
      // Also get and store the Player ID in backend
      final playerId = OneSignal.User.pushSubscription.id;
      if (playerId != null) {
        print('📱 Registering Player ID: $playerId');
        // Import UserApiService if not already imported
        // UserApiService.registerOneSignalPlayerId(firebaseUid, playerId);
      }
    } catch (e) {
      print('❌ Error setting external user ID: $e');
    }
  }
  
  /// Remove external user ID (on logout)
  static Future<void> removeExternalUserId() async {
    try {
      await OneSignal.logout();
      print('✅ OneSignal external user ID removed');
    } catch (e) {
      print('❌ Error removing external user ID: $e');
    }
  }
  
  /// Send a tag (for user segmentation)
  static Future<void> sendTag(String key, String value) async {
    try {
      await OneSignal.User.addTagWithKey(key, value);
      print('✅ OneSignal tag sent: $key = $value');
    } catch (e) {
      print('❌ Error sending tag: $e');
    }
  }
  
  /// Send multiple tags
  static Future<void> sendTags(Map<String, String> tags) async {
    try {
      await OneSignal.User.addTags(tags);
      print('✅ OneSignal tags sent: $tags');
    } catch (e) {
      print('❌ Error sending tags: $e');
    }
  }
  
  /// Delete a tag
  static Future<void> deleteTag(String key) async {
    try {
      await OneSignal.User.removeTag(key);
      print('✅ OneSignal tag deleted: $key');
    } catch (e) {
      print('❌ Error deleting tag: $e');
    }
  }
}
