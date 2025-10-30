import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class HelpRequestApiService {
  // Create a new help request
  static Future<Map<String, dynamic>?> createHelpRequest({
    required String firebaseUid,
    required String title,
    required String description,
    required String category,
    String urgency = 'Medium',
    Map<String, dynamic>? location,
    bool anonymous = false,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.helpRequestsEndpoint}';
      final body = jsonEncode({
        'firebaseUid': firebaseUid,
        'title': title,
        'description': description,
        'category': category,
        'urgency': urgency,
        'location': location,
        'anonymous': anonymous,
      });
      
      print('🌐 Creating help request...');
      print('📍 URL: $url');
      print('📦 Body: $body');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        ApiConfig.connectionTimeout,
        onTimeout: () {
          print('⏰ Connection timeout!');
          print('Make sure backend is running: $url');
          throw Exception('Connection timeout - make sure backend server is running on ${ApiConfig.baseUrl}');
        },
      );

      print('✅ Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('❌ Server returned error: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to create help request: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in createHelpRequest: $e');
      rethrow; // Re-throw to see full error in caller
    }
  }

  // Get all help requests with optional filters
  static Future<List<dynamic>> getAllHelpRequests({
    String? status,
    String? category,
    int limit = 50,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'page': page.toString(),
      };
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.helpRequestsEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      print('Error in getAllHelpRequests: $e');
      return [];
    }
  }

  // Get help request by ID
  static Future<Map<String, dynamic>?> getHelpRequestById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.helpRequestsEndpoint}/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error in getHelpRequestById: $e');
      return null;
    }
  }

  // Accept a help request (volunteer to help)
  static Future<bool> acceptHelpRequest(String id, String firebaseUid) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.helpRequestsEndpoint}/$id/accept'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'firebaseUid': firebaseUid}),
      ).timeout(ApiConfig.connectionTimeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Error in acceptHelpRequest: $e');
      return false;
    }
  }

  // Complete a help request
  static Future<bool> completeHelpRequest(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.helpRequestsEndpoint}/$id/complete'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Error in completeHelpRequest: $e');
      return false;
    }
  }

  // Get nearby help requests
  static Future<List<dynamic>> getNearbyHelpRequests({
    required double longitude,
    required double latitude,
    int maxDistance = 5000,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.helpRequestsEndpoint}/nearby')
          .replace(queryParameters: {
        'longitude': longitude.toString(),
        'latitude': latitude.toString(),
        'maxDistance': maxDistance.toString(),
      });

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      print('Error in getNearbyHelpRequests: $e');
      return [];
    }
  }

  // Get user's own posts
  static Future<List<dynamic>> getUserPosts(String firebaseUid) async {
    try {
      print('🔵 Fetching posts for user: $firebaseUid');
      
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.helpRequestsEndpoint}')
          .replace(queryParameters: {'userId': firebaseUid});
      print('📍 URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(ApiConfig.connectionTimeout);

      print('✅ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        print('📦 Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error in getUserPosts: $e');
      return [];
    }
  }

  // Get posts accepted by user (posts where user is the helper)
  static Future<List<dynamic>> getAcceptedPosts(String firebaseUid) async {
    try {
      print('🔵 Fetching accepted posts for user: $firebaseUid');
      
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.helpRequestsEndpoint}')
          .replace(queryParameters: {'helperId': firebaseUid});
      print('📍 URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(ApiConfig.connectionTimeout);

      print('✅ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        print('📦 Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error in getAcceptedPosts: $e');
      return [];
    }
  }

  // Update help request
  static Future<Map<String, dynamic>?> updateHelpRequest({
    required String requestId,
    required String firebaseUid,
    String? title,
    String? description,
    String? category,
    String? urgency,
    Map<String, dynamic>? location,
    List<String>? images,
  }) async {
    try {
      print('🔵 Updating help request: $requestId');
      
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.helpRequestsEndpoint}/$requestId');
      print('📍 URL: $url');

      final Map<String, dynamic> body = {
        'firebaseUid': firebaseUid,
      };
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (category != null) body['category'] = category;
      if (urgency != null) body['urgency'] = urgency;
      if (location != null) body['location'] = location;
      if (images != null) body['images'] = images;

      print('📦 Body: ${jsonEncode(body)}');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(ApiConfig.connectionTimeout);

      print('✅ Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        throw Exception('Failed to update help request: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in updateHelpRequest: $e');
      rethrow;
    }
  }

  // Delete help request
  static Future<bool> deleteHelpRequest({
    required String requestId,
    required String firebaseUid,
  }) async {
    try {
      print('🔵 Deleting help request: $requestId');
      
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.helpRequestsEndpoint}/$requestId?firebaseUid=$firebaseUid');
      print('📍 URL: $url');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(ApiConfig.connectionTimeout);

      print('✅ Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        throw Exception('Failed to delete help request: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in deleteHelpRequest: $e');
      rethrow;
    }
  }
}
