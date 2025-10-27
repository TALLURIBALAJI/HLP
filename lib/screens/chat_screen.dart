import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../theme.dart';
import '../services/chat_api_service.dart';
import '../services/api_config.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String otherUserEmail;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _chatId;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  void _initializeSocket() {
    // Connect to Socket.io server (remove /api suffix for Socket.io)
    final socketUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    print('🔌 Connecting to Socket.io: $socketUrl');
    
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('✅ Socket.io connected: ${socket.id}');
    });

    socket.on('receive_message', (data) {
      print('📨 Received message: $data');
      setState(() {
        _messages.add(data);
      });
      
      // Scroll to bottom
      if (_scrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });

    socket.onDisconnect((_) {
      print('❌ Socket.io disconnected');
    });

    socket.onError((error) {
      print('🚨 Socket.io error: $error');
    });
  }

  Future<void> _initializeChat() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Create or get existing chat
      final chat = await ChatApiService.createOrGetChat(
        user1Id: currentUser.uid,
        user2Id: widget.otherUserId,
      );

      setState(() {
        _chatId = chat['_id'];
      });

      // Join the chat room via Socket.io
      socket.emit('join_chat', _chatId);
      print('👥 Joined chat room: $_chatId');

      // Load existing messages
      await _loadMessages();
    } catch (e) {
      print('Error initializing chat: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages({bool showLoading = true}) async {
    if (_chatId == null) return;

    if (showLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final messages = await ChatApiService.getMessages(_chatId!);

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });

        // Scroll to bottom
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (mounted && showLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    print('🔘 Send button pressed');
    
    if (_messageController.text.trim().isEmpty) {
      print('⚠️ Message is empty');
      return;
    }
    
    if (_chatId == null) {
      print('⚠️ Chat ID is null');
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('⚠️ Current user is null');
      return;
    }

    final messageText = _messageController.text.trim();
    print('📝 Sending message: $messageText');
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      print('📤 Calling ChatApiService.sendMessage...');
      // Send message to backend
      final response = await ChatApiService.sendMessage(
        chatId: _chatId!,
        senderId: currentUser.uid,
        message: messageText,
      );

      print('✅ Message saved to backend: ${response['messageData']}');

      // Emit message via Socket.io for real-time delivery
      print('📡 Emitting via Socket.io...');
      socket.emit('send_message', {
        'chatId': _chatId,
        'message': response['messageData'],
      });

      print('📤 Message sent via Socket.io');
    } catch (e, stackTrace) {
      print('❌ Error sending message: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                widget.otherUserName.isNotEmpty ? widget.otherUserName[0].toUpperCase() : 'A',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.otherUserEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              print('🔄 Refresh button pressed');
              _loadMessages(showLoading: false);
            },
            tooltip: 'Refresh messages',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final senderId = message['sender'] is Map
                          ? message['sender']['firebaseUid']
                          : message['sender'];
                      final senderName = message['sender'] is Map
                          ? message['sender']['username']
                          : 'Unknown';
                      final messageText = message['message']?.toString() ?? '';
                      final timestamp = message['createdAt']?.toString() ?? '';
                      final isMe = senderId == currentUser?.uid;

                      return _buildMessageBubble(
                        message: messageText,
                        isMe: isMe,
                        senderName: senderName,
                        timestamp: timestamp,
                      );
                    },
                  ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    radius: 24,
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white, size: 20),
                            onPressed: _sendMessage,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isMe,
    required String senderName,
    required String timestamp,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              child: Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : 'A',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  if (!isMe) const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              child: Text(
                'You'[0],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return '';
    }
  }
}
