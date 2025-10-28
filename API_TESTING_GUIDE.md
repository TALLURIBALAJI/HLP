# 🧪 API Testing Guide for Karma System

## Test All Karma Features

### Base URL
```
http://localhost:3000/api
or
http://10.93.252.199:3000/api (for emulator)
```

---

## 1. Test Feedback System (+5 karma)

### Submit Feedback
```bash
POST /api/feedback
Content-Type: application/json

{
  "firebaseUid": "YOUR_FIREBASE_UID",
  "helpRequestId": "HELP_REQUEST_ID",
  "rating": 5,
  "comment": "Excellent help!"
}
```

### Get User Feedback
```bash
GET /api/feedback/user/YOUR_FIREBASE_UID
```

**Expected Result:** User gets +5 karma if rating >= 4

---

## 2. Test Donation System (+15 karma)

### Create Donation
```bash
POST /api/donations
Content-Type: application/json

{
  "firebaseUid": "YOUR_FIREBASE_UID",
  "title": "Engineering Mathematics Book",
  "description": "Semester 1 textbook in good condition",
  "category": "Books",
  "location": {
    "address": "Main Library, Block A"
  }
}
```

### Get All Donations
```bash
GET /api/donations?status=Available
```

### Claim Donation
```bash
POST /api/donations/DONATION_ID/claim
Content-Type: application/json

{
  "firebaseUid": "YOUR_FIREBASE_UID"
}
```

**Expected Result:** Creator gets +15 karma immediately on posting

---

## 3. Test Event/Volunteering System (+25 karma)

### Create Event
```bash
POST /api/events
Content-Type: application/json

{
  "firebaseUid": "ORGANIZER_FIREBASE_UID",
  "title": "Beach Cleanup Drive",
  "description": "Join us to clean the beach!",
  "category": "Environment",
  "eventDate": "2025-12-01T09:00:00Z",
  "volunteersNeeded": 20,
  "location": {
    "address": "Marina Beach"
  }
}
```

### Register as Volunteer
```bash
POST /api/events/EVENT_ID/volunteer
Content-Type: application/json

{
  "firebaseUid": "VOLUNTEER_FIREBASE_UID"
}
```

### Mark Attendance (After Event)
```bash
PUT /api/events/EVENT_ID/attendance
Content-Type: application/json

{
  "volunteerId": "MONGO_USER_ID"
}
```

**Expected Result:** Volunteer gets +25 karma when marked as attended

---

## 4. Test Report System (+3 karma)

### Submit Report
```bash
POST /api/reports
Content-Type: application/json

{
  "firebaseUid": "REPORTER_FIREBASE_UID",
  "reportedContentType": "HelpRequest",
  "reportedContentId": "HELP_REQUEST_ID",
  "reason": "Spam",
  "description": "This looks like a fake post"
}
```

### Get All Reports (Admin)
```bash
GET /api/reports?status=Pending
```

### Verify Report (Admin/Moderator)
```bash
PUT /api/reports/REPORT_ID/verify
Content-Type: application/json

{
  "firebaseUid": "ADMIN_FIREBASE_UID",
  "isVerified": true
}
```

**Expected Result:** Reporter gets +3 karma if report is verified

---

## 5. Check User Karma

### Get User Profile
```bash
GET /api/users/firebase/YOUR_FIREBASE_UID
```

**Response includes:**
```json
{
  "karma": 45,
  "helpRequestsCreated": 2,
  "helpRequestsFulfilled": 1,
  ...
}
```

---

## 6. Test Existing Features

### Create Help Request (+2 karma)
```bash
POST /api/help-requests
Content-Type: application/json

{
  "firebaseUid": "YOUR_FIREBASE_UID",
  "title": "Need groceries",
  "description": "Can someone help me buy groceries?",
  "category": "Food",
  "urgency": "High",
  "location": {
    "address": "Hostel Block B"
  }
}
```

### Accept Help Request (+10 karma)
```bash
POST /api/help-requests/REQUEST_ID/accept
Content-Type: application/json

{
  "firebaseUid": "HELPER_FIREBASE_UID"
}
```

### Complete Help Request (+20 karma to helper)
```bash
PUT /api/help-requests/REQUEST_ID/complete
```

---

## Testing Checklist

- [ ] Create help request → Check karma (+2)
- [ ] Accept help request → Check karma (+10)
- [ ] Complete help request → Check karma (+20)
- [ ] Post donation → Check karma (+15)
- [ ] Register for event → No karma yet
- [ ] Mark attendance → Check karma (+25)
- [ ] Submit feedback (rating ≥4) → Check karma (+5)
- [ ] Submit report → No karma yet
- [ ] Admin verifies report → Check karma (+3)

---

## Quick Test Script

You can test using cURL, Postman, or this Node.js script:

```javascript
// test-karma.js
const axios = require('axios');
const BASE_URL = 'http://localhost:3000/api';
const YOUR_UID = 'YOUR_FIREBASE_UID_HERE';

async function testKarma() {
  // 1. Check initial karma
  let user = await axios.get(`${BASE_URL}/users/firebase/${YOUR_UID}`);
  console.log('Initial Karma:', user.data.data.karma);
  
  // 2. Create donation
  await axios.post(`${BASE_URL}/donations`, {
    firebaseUid: YOUR_UID,
    title: 'Test Book',
    description: 'Testing donation',
    category: 'Books'
  });
  
  // 3. Check karma again
  user = await axios.get(`${BASE_URL}/users/firebase/${YOUR_UID}`);
  console.log('After Donation (+15):', user.data.data.karma);
}

testKarma();
```

---

## Expected Karma Flow Example

Starting karma: 0

1. Create help request: **2 karma**
2. Post donation: **17 karma** (+15)
3. Accept someone's help request: **27 karma** (+10)
4. Complete that request: **47 karma** (+20)
5. Get 5-star feedback: **52 karma** (+5)
6. Volunteer at event: **77 karma** (+25)
7. Report verified: **80 karma** (+3)

**Total: 80 karma points!** 🎉

---

## Notes

- All karma awards are automatic
- Notifications are sent for each karma award
- Duplicate actions are prevented (e.g., can't rate same request twice)
- Backend validates all inputs
- Error messages are descriptive

**All endpoints are live and ready to test!** ✅
