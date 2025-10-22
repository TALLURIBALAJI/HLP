# HelpLink Backend API Integration

## ✅ Completed Setup

### Backend Server
- **Location**: `backend/` folder
- **Server URL**: `http://localhost:3000`
- **Database**: MongoDB Atlas (helplink database)
- **Status**: ✅ Running and connected

### Flutter Integration
- **API Services**: Created in `lib/services/`
- **HTTP Package**: Added to `pubspec.yaml`
- **Auto-sync**: Users automatically sync to MongoDB on sign-in/sign-up

## 🚀 Running the Backend

### Start the Server:
```bash
cd backend
node src/server.js
```

The server will run on `http://localhost:3000`

### Available Endpoints:

#### Users
- `POST /api/users` - Create/update user
- `GET /api/users/:firebaseUid` - Get user by Firebase UID
- `PATCH /api/users/:firebaseUid/karma` - Update karma points
- `GET /api/users/leaderboard/top` - Get leaderboard

#### Help Requests
- `POST /api/help-requests` - Create new help request
- `GET /api/help-requests` - Get all help requests (with filters)
- `GET /api/help-requests/nearby` - Get nearby requests
- `GET /api/help-requests/:id` - Get specific request
- `PATCH /api/help-requests/:id/accept` - Accept a request
- `PATCH /api/help-requests/:id/complete` - Mark as completed

## 📱 Flutter App Integration

### API Services Created:
1. **`api_config.dart`** - Base URLs and configuration
2. **`user_api_service.dart`** - User-related API calls
3. **`help_request_api_service.dart`** - Help request API calls

### Auto-sync Features:
- ✅ Sign up: Creates user in MongoDB
- ✅ Sign in: Syncs/updates user in MongoDB
- ✅ Google Sign-In: Syncs user with profile photo

## 🔧 Testing

### Test if server is running:
Open browser: `http://localhost:3000`

Should see:
```json
{
  "message": "🚀 HelpLink API Server",
  "version": "1.0.0",
  "status": "running"
}
```

### Test user creation:
```bash
# PowerShell
$body = @{
    firebaseUid = "test123"
    email = "test@example.com"
    username = "Test User"
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:3000/api/users `
    -Method POST `
    -Body $body `
    -ContentType "application/json"
```

## ⚙️ Configuration

### Android Emulator:
- Uses `10.0.2.2:3000` to access localhost
- Configured in `lib/services/api_config.dart`

### Physical Device:
- Replace `10.0.2.2` with your computer's IP address
- Example: `http://192.168.1.100:3000`

## 📦 Database Collections

### Users Collection:
- firebaseUid (unique)
- username
- email
- mobile
- profileImage
- karma
- helpRequestsCreated
- helpRequestsFulfilled
- timestamps

### HelpRequests Collection:
- userId (ref to User)
- title
- description
- category
- urgency
- status
- location (GeoJSON)
- helperId (ref to User)
- karmaPoints
- timestamps

## 🎯 Next Steps

1. ✅ Backend server running
2. ✅ MongoDB connected
3. ✅ Flutter app integrated
4. ⏳ Test sign-up/sign-in to verify sync
5. ⏳ Implement help request creation UI
6. ⏳ Add AWS S3 for image uploads
7. ⏳ Add OneSignal for notifications
8. ⏳ Add Socket.io for real-time chat

## 🐛 Troubleshooting

### Backend server won't start:
- Check if MongoDB IP is whitelisted in Atlas
- Verify `.env` file has correct connection string
- Run `npm install` if dependencies missing

### Flutter can't connect:
- Make sure backend server is running
- Check `api_config.dart` has correct base URL
- For Android Emulator, use `10.0.2.2` not `localhost`
- Check Windows Firewall isn't blocking port 3000
