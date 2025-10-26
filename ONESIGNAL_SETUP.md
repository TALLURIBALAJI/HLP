# 🔔 OneSignal Push Notifications - Complete Setup Guide

## ✅ **STEP 1: Get Firebase Service Account JSON**

### ⚠️ **IMPORTANT: You need SERVICE ACCOUNT JSON (not google-services.json!)**

### **How to Download:**
1. Go to: https://console.firebase.google.com
2. Select your project: **"helplink-d1ab6"**
3. Click **⚙️ GEAR icon** → **"Project settings"**
4. Click **"Service accounts"** tab (at the top)
5. Scroll down to "Firebase Admin SDK" section
6. Click **"Generate new private key"** button
7. Click **"Generate key"** in the popup
8. A JSON file will download (filename like: `helplink-d1ab6-firebase-adminsdk-xxxxx-1234567890.json`)
9. **Save it to your Desktop**

### ⚠️ **SECURITY WARNING:**
This file contains **PRIVATE KEYS** with admin access to your Firebase project!
- ❌ Never commit to Git/GitHub
- ❌ Never share publicly
- ✅ Keep it safe like a password
- ✅ Already added to .gitignore for you

---

## ✅ **STEP 2: Upload Service Account JSON to OneSignal**

### **What to Upload:**
📄 **File Location**: `C:\Users\venki\OneDrive\Desktop\hlp\android\app\google-services.json`

## ✅ **STEP 2: Upload Service Account JSON to OneSignal**

### **What to Upload:**
📄 **File**: The JSON file you just downloaded from Firebase (e.g., `helplink-d1ab6-firebase-adminsdk-xxxxx-1234567890.json`)
**NOT** the `google-services.json` file!

### **How to Upload:**
1. Go to: https://app.onesignal.com/
2. Click **"New App/Website"**
3. Enter App Name: **"HelpLink"**
4. Select Platform: **"Google Android (FCM)"**
5. Click **"Upload JSON File"** button
6. Select the **Service Account JSON** file you downloaded
7. Click **"Save & Continue"**

---

## ✅ **STEP 3: Get Your OneSignal App ID**

After uploading, OneSignal will show you:
- **App ID**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- **REST API Key**: (for backend)

📝 **Copy both and save them!**

---

## ✅ **STEP 3: Update Flutter App with Your App ID**

### **Edit this file:**
📂 `lib/services/notification_service.dart`

### **Find this line (line 6):**
```dart
static const String _oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID_HERE';
```

### **Replace with your actual App ID:**
```dart
static const String _oneSignalAppId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
```

---

## ✅ **STEP 4: Install Packages**

Run this command:
```powershell
flutter pub get
```

---

## ✅ **STEP 5: Test Notifications**

### **Test from OneSignal Dashboard:**
1. Go to: https://app.onesignal.com/
2. Select your "HelpLink" app
3. Click **"Messages" → "New Push"**
4. Title: `Test Notification`
5. Message: `Hello from OneSignal!`
6. Click **"Send to All Subscribed Users"**

### **Test on Your Phone:**
1. Run your app: `flutter run`
2. Allow notification permissions
3. Send test notification from dashboard
4. You should see the notification! 🎉

---

## ✅ **STEP 6: Link OneSignal with Firebase User**

When user signs in, call:
```dart
await NotificationService.setExternalUserId(firebaseUid);
```

This allows you to send notifications to specific users!

---

## 🎯 **Notification Types You Can Send**

### **1. New Help Request Posted**
```json
{
  "type": "new_help_request",
  "requestId": "12345",
  "category": "Food"
}
```

### **2. Your Request Was Accepted**
```json
{
  "type": "request_accepted",
  "requestId": "12345",
  "helperName": "John Doe"
}
```

### **3. Your Request Was Completed (+20 Karma!)**
```json
{
  "type": "request_completed",
  "requestId": "12345",
  "karmaEarned": 20
}
```

### **4. New Message**
```json
{
  "type": "new_message",
  "senderId": "abc123",
  "senderName": "Jane Smith"
}
```

---

## 🔧 **Backend Integration (Step 7)**

### **Install OneSignal SDK in Backend:**
```bash
cd backend
npm install onesignal-node
```

### **Create notification service in backend:**
📂 `backend/src/services/notificationService.js`

```javascript
import * as OneSignal from 'onesignal-node';

const client = new OneSignal.Client({
  userAuthKey: 'YOUR_USER_AUTH_KEY',
  app: {
    appAuthKey: 'YOUR_REST_API_KEY',
    appId: 'YOUR_ONESIGNAL_APP_ID'
  }
});

export async function sendNotificationToUser(firebaseUid, title, message, data) {
  try {
    const notification = {
      contents: { en: message },
      headings: { en: title },
      data: data,
      filters: [
        { field: 'tag', key: 'firebase_uid', relation: '=', value: firebaseUid }
      ]
    };

    const response = await client.createNotification(notification);
    console.log('✅ Notification sent:', response.body.id);
    return response;
  } catch (error) {
    console.error('❌ Error sending notification:', error);
    throw error;
  }
}

export async function sendNotificationToAll(title, message, data) {
  try {
    const notification = {
      contents: { en: message },
      headings: { en: title },
      data: data,
      included_segments: ['All']
    };

    const response = await client.createNotification(notification);
    console.log('✅ Notification sent to all:', response.body.id);
    return response;
  } catch (error) {
    console.error('❌ Error sending notification:', error);
    throw error;
  }
}
```

---

## 📱 **Usage Examples**

### **When User Signs In:**
```dart
final firebaseUid = FirebaseAuth.instance.currentUser!.uid;
await NotificationService.setExternalUserId(firebaseUid);
```

### **When User Signs Out:**
```dart
await NotificationService.removeExternalUserId();
```

### **Tag User by Category:**
```dart
await NotificationService.sendTag('favorite_category', 'Food');
```

### **Send Multiple Tags:**
```dart
await NotificationService.sendTags({
  'karma_level': '150',
  'badge': 'Community Contributor',
  'city': 'New York'
});
```

---

## ✅ **Checklist**

- [ ] Upload `google-services.json` to OneSignal
- [ ] Copy OneSignal App ID and REST API Key
- [ ] Update `notification_service.dart` with App ID
- [ ] Run `flutter pub get`
- [ ] Test notification from OneSignal dashboard
- [ ] Link users with `setExternalUserId()`
- [ ] Install `onesignal-node` in backend
- [ ] Create backend notification service
- [ ] Send notifications on events:
  - [ ] New help request posted
  - [ ] Request accepted (+10 karma)
  - [ ] Request completed (+20 karma)
  - [ ] New message received
  - [ ] Badge unlocked

---

## 🎉 **You're Done!**

Your app now has push notifications! Users will be notified when:
- New help requests are posted in their area
- Someone accepts their request
- Their help is completed (karma earned!)
- They receive messages
- They unlock new badges

---

## 🆘 **Troubleshooting**

### **Notifications not working?**
1. Check App ID is correct in `notification_service.dart`
2. Make sure notification permissions are granted on phone
3. Check OneSignal dashboard → Delivery → Subscribed Users (should be > 0)
4. Try sending test notification from dashboard

### **Can't upload JSON file?**
- Make sure you're selecting `google-services.json` (not any other JSON)
- File should be from: `android/app/google-services.json`

### **Player ID is null?**
- Wait a few seconds after app starts
- Check internet connection
- Make sure App ID is correct

---

## 📚 **Resources**

- OneSignal Dashboard: https://app.onesignal.com/
- OneSignal Flutter SDK: https://documentation.onesignal.com/docs/flutter-sdk-setup
- OneSignal REST API: https://documentation.onesignal.com/reference/create-notification
