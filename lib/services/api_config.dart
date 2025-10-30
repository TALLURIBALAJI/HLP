import 'dart:io';

class ApiConfig {
  // ========================================
  // 🔧 CONFIGURATION GUIDE
  // ========================================
  // 
  // FOR LOCAL DEVELOPMENT (same WiFi):
  // 1. Find your computer's IP: Run 'ipconfig' in Windows PowerShell
  // 2. Look for "IPv4 Address" (usually starts with 192.168.x.x or 10.x.x.x)
  // 3. Update _localIpAddress below with your IP
  // 4. Make sure backend server is running: cd backend && npm start
  // 5. Make sure Windows Firewall allows port 3000
  //
  // FOR PRODUCTION:
  // 1. Deploy backend to cloud (Heroku, Railway, AWS, etc.)
  // 2. Update _productionUrl with your deployed URL
  // 3. Set _useProduction = true
  // 
  // ========================================
  
  // 🏠 Your computer's local IP address (for physical device on same WiFi)
  // Run 'ipconfig' in PowerShell to find it
  static const String _localIpAddress = '10.93.252.199';  // ⬅️ UPDATE THIS WITH YOUR IP
  
  // 🌐 Production server URL (when deployed to cloud)
  static const String _productionUrl = 'https://your-app.herokuapp.com/api';  // ⬅️ UPDATE WHEN DEPLOYED
  
  // 🔀 Switch between local and production
  static const bool _useProduction = false;  // Set to true when using production server
  
  // ========================================
  // AUTO-DETECTION (No need to modify below)
  // ========================================
  
  // 📱 Set this to true when running on physical device
  static const bool _usePhysicalDevice = true;  // ⬅️ SET TO true FOR PHYSICAL PHONE
  
  static String get baseUrl {
    if (_useProduction) {
      // Production mode
      return _productionUrl;
    }
    
    // Local development mode
    if (Platform.isAndroid) {
      if (_usePhysicalDevice) {
        // Physical Android device - use computer's IP
        return 'http://$_localIpAddress:3000/api';
      } else {
        // Android Emulator - use emulator address
        return 'http://10.0.2.2:3000/api';
      }
    } else if (Platform.isIOS) {
      // iOS Simulator can use localhost directly
      return 'http://localhost:3000/api';
    }
    
    // Default for other platforms
    return 'http://$_localIpAddress:3000/api';
  }
  
  // Endpoints
  static const String usersEndpoint = '/users';
  static const String helpRequestsEndpoint = '/help-requests';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // ========================================
  // DEBUG INFO
  // ========================================
  static void printDebugInfo() {
    print('🌐 API Configuration:');
    print('   Platform: ${Platform.operatingSystem}');
    print('   Mode: ${_useProduction ? "PRODUCTION" : "LOCAL DEVELOPMENT"}');
    print('   Device: ${_usePhysicalDevice ? "PHYSICAL DEVICE" : "EMULATOR"}');
    print('   Base URL: $baseUrl');
    print('   Local IP: $_localIpAddress');
  }
}
