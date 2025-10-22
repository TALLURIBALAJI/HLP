class ApiConfig {
  // For Android Emulator, use 10.0.2.2 to access localhost
  // For iOS Simulator, use localhost or 127.0.0.1
  // For Physical device, use your computer's IP address
  
  // Change this based on your setup:
  // - Emulator: 'http://10.0.2.2:3000/api'
  // - Physical Device: 'http://YOUR_COMPUTER_IP:3000/api'
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Endpoints
  static const String usersEndpoint = '/users';
  static const String helpRequestsEndpoint = '/help-requests';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
