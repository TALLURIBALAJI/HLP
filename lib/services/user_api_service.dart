import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserApiService {
  // Create or update user in MongoDB
  static Future<Map<String, dynamic>> createOrUpdateUser({
    required String firebaseUid,
    required String email,
    String? username,
    String? mobile,
    String? profileImage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebaseUid': firebaseUid,
          'email': email,
          'username': username ?? email.split('@')[0],
          'mobile': mobile,
          'profileImage': profileImage,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to create/update user');
      }
    } catch (e) {
      print('Error in createOrUpdateUser: $e');
      rethrow;
    }
  }

  // Get user by Firebase UID
  static Future<Map<String, dynamic>?> getUserByFirebaseUid(String firebaseUid) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$firebaseUid'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get user');
      }
    } catch (e) {
      print('Error in getUserByFirebaseUid: $e');
      return null;
    }
  }

  // Update user karma
  static Future<bool> updateUserKarma(String firebaseUid, int karmaChange) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$firebaseUid/karma'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'karmaChange': karmaChange}),
      ).timeout(ApiConfig.connectionTimeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Error in updateUserKarma: $e');
      return false;
    }
  }

  // Get leaderboard
  static Future<List<dynamic>> getLeaderboard({int limit = 100}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/leaderboard/top?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      print('Error in getLeaderboard: $e');
      return [];
    }
  }
}
