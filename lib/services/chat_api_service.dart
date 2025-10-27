import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ChatApiService {
  // Create or get existing chat between two users
  static Future<Map<String, dynamic>> createOrGetChat({
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      print('🔵 createOrGetChat called:');
      print('   user1Id: $user1Id');
      print('   user2Id: $user2Id');
      print('   URL: ${ApiConfig.baseUrl}/chats');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chats'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user1Id': user1Id,
          'user2Id': user2Id,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      print('🔵 Response status: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['chat'];
      } else {
        throw Exception('Failed to create/get chat - Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error in createOrGetChat: $e');
      rethrow;
    }
  }

  // Get messages for a chat
  static Future<List<dynamic>> getMessages(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chats/$chatId/messages'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['messages'] ?? [];
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error in getMessages: $e');
      return [];
    }
  }

  // Send a message
  static Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String senderId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chats/$chatId/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderId': senderId,
          'message': message,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Error in sendMessage: $e');
      rethrow;
    }
  }

  // Get all chats for a user
  static Future<List<dynamic>> getUserChats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chats/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['chats'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error in getUserChats: $e');
      return [];
    }
  }
}
