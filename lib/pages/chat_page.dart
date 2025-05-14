// ignore_for_file: unnecessary_cast

import 'dart:convert';

import 'package:craft/pages/chat_bot_handler.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? attachmentPath;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.attachmentPath,
  });

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'attachmentPath': attachmentPath,
    };
  }

  // Create from map for retrieval
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'],
      isUser: map['isUser'],
      timestamp: DateTime.parse(map['timestamp']),
      attachmentPath: map['attachmentPath'],
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  bool _isBotTyping = false;

  // Chat bot handler for AI-powered responses
  // ignore: unused_field
  final ChatBotHandler _chatBotHandler = ChatBotHandler();

  // Quick replies for common questions
  final List<String> _quickReplies = [
    'How do I place an order?',
    'What are your shipping options?',
    'Do you offer customization?',
    'What payment methods do you accept?',
  ];

  // Initial welcome message
  final String _welcomeMessage = 'Welcome to Craft! How can I help you today?';

  @override
  void initState() {
    super.initState();
    _loadMessages();

    // Show welcome message if this is first time
    Future.delayed(Duration.zero, () {
      if (_messages.isEmpty) {
        _receiveAutomaticMessage(_welcomeMessage);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Load messages from storage
  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('chat_messages');

      if (messagesJson != null) {
        final List<dynamic> messagesData = jsonDecode(messagesJson);

        setState(() {
          _messages.clear();
          for (var data in messagesData) {
            _messages.add(ChatMessage.fromMap(data));
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error loading chat history');
    }
  }

  // Save messages to storage
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(_messages.map((m) => m.toMap()).toList());
      await prefs.setString('chat_messages', messagesJson);
    } catch (e) {
      _showSnackBar('Error saving chat history');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        backgroundColor: Colors.black,
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _isComposing = false;

      // Add user message
      final message = ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _messages.insert(0, message);
    });

    _saveMessages();
    _focusNode.requestFocus();

    // Simulate bot typing and response
    _simulateBotResponse(text);
  }

  void _simulateBotResponse(String userMessage) {
    // Set bot typing indicator
    setState(() {
      _isBotTyping = true;
    });

    // Calculate response time based on message length (more realistic)
    final int responseTime = 500 + (userMessage.length * 30).clamp(500, 2000);

    // Delayed response
    Future.delayed(Duration(milliseconds: responseTime), () {
      if (!mounted) return;

      setState(() {
        _isBotTyping = false;
      });

      // Get appropriate response
      String botResponse = _getBotResponse(userMessage);
      _receiveAutomaticMessage(botResponse);
    });
  }

  void _receiveAutomaticMessage(String text) {
    final message = ChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, message);
    });

    _saveMessages();
  }

  String _getBotResponse(String userMessage) {
    // Convert to lowercase for easier comparison
    final lowerUserMsg = userMessage.toLowerCase();

    // Check for keywords and provide appropriate responses
    if (lowerUserMsg.contains('hello') ||
        lowerUserMsg.contains('hi') ||
        lowerUserMsg.contains('hey')) {
      return 'Hello! How can I help you today?';
    } else if (lowerUserMsg.contains('shipping') ||
        lowerUserMsg.contains('delivery')) {
      return 'We offer standard shipping (3-5 days) and express shipping (1-2 days). Shipping costs vary based on location.';
    } else if (lowerUserMsg.contains('order') ||
        lowerUserMsg.contains('purchase')) {
      return 'You can place an order by selecting a product, clicking "View Details", and then tapping the "Add to Cart" button.';
    } else if (lowerUserMsg.contains('custom') ||
        lowerUserMsg.contains('personalize')) {
      return 'Yes, we offer customization for many products! Please let us know your specific requirements, and our artisans will work to create something special for you.';
    } else if (lowerUserMsg.contains('payment') ||
        lowerUserMsg.contains('pay')) {
      return 'We accept credit/debit cards, mobile payments, and cash on delivery.';
    } else if (lowerUserMsg.contains('thank')) {
      return 'You\'re welcome! Is there anything else I can help you with?';
    } else if (lowerUserMsg.contains('material') ||
        lowerUserMsg.contains('made of')) {
      return 'Our products are made from high-quality, eco-friendly materials sourced from local suppliers. Each product page contains detailed material information.';
    } else if (lowerUserMsg.contains('refund') ||
        lowerUserMsg.contains('return')) {
      return 'We offer a 30-day return policy for most items. Please contact us within 30 days of receiving your order if you wish to return it.';
    }

    // Default response if no keywords matched
    return 'Thank you for your message! Our team will get back to you shortly. In the meantime, feel free to browse our collections or ask me another question.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Chat header
          _buildChatHeader(),

          // Messages list
          Expanded(child: _buildMessageList()),

          // Quick replies
          _buildQuickReplies(),

          // Divider
          const Divider(height: 1.0),

          // Chat composer
          _buildChatComposer(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Chat Support',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {
            // Show chat options menu
            showModalBottomSheet(
              context: context,
              builder: (context) => _buildChatOptionsSheet(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.support_agent,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Craft Support',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            radius: 18,
            child: IconButton(
              icon: const Icon(Icons.phone_outlined,
                  color: Colors.black, size: 18),
              onPressed: () {
                _showSnackBar('Call feature coming soon!');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        image: const DecorationImage(
          image: AssetImage('Assets/background_pattern.svg'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        reverse: true,
        itemCount: _messages.length + (_isBotTyping ? 1 : 0),
        itemBuilder: (context, index) {
          // Show typing indicator at index 0 if bot is typing
          if (_isBotTyping && index == 0) {
            return _buildTypingIndicator();
          }

          // Adjust index if bot is typing
          final adjustedIndex = _isBotTyping ? index - 1 : index;
          if (adjustedIndex < 0 || adjustedIndex >= _messages.length) {
            return const SizedBox.shrink();
          }

          final ChatMessage message = _messages[adjustedIndex];
          return _buildMessageItem(message, context);
        },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            _buildDot(150),
            _buildDot(300),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int delay) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        shape: BoxShape.circle,
      ),
      child: TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value as double,
            child: Transform.scale(
              scale: 0.5 + 0.5 * (value as double),
              child: child,
            ),
          );
        },
        child: const SizedBox(),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, BuildContext context) {
    // Format timestamp
    final String formattedTime =
        DateFormat('hh:mm a').format(message.timestamp);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16.0,
                    ),
                  ),
                  // Attachment if exists
                  if (message.attachmentPath != null)
                    Container(
                      height: 150,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: DecorationImage(
                          image: AssetImage(message.attachmentPath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 8.0, left: 8.0),
              child: Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 11.0,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _quickReplies.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12.0),
            child: OutlinedButton(
              onPressed: () => _handleSubmitted(_quickReplies[index]),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                side: BorderSide(color: Colors.grey[300]!),
                backgroundColor: Colors.white,
              ),
              child: Text(
                _quickReplies[index],
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black54),
            onPressed: _showAttachmentOptions,
          ),
          // Text field
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: _isComposing ? _handleSubmitted : null,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          // Send button
          Container(
            decoration: BoxDecoration(
              color: _isComposing ? Colors.black : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              color: _isComposing ? Colors.white : Colors.grey[500],
              onPressed: _isComposing
                  ? () => _handleSubmitted(_textController.text)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Attachment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo,
                  label: 'Photo',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Photo attachment coming soon!');
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Camera attachment coming soon!');
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.location_on,
                  label: 'Location',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Location sharing coming soon!');
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.file_present,
                  label: 'Document',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _showSnackBar('Document sharing coming soon!');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatOptionsSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Chat Options',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 20.0),
          _buildOptionTile(
            icon: Icons.delete_outline,
            title: 'Clear Chat History',
            onTap: () {
              Navigator.pop(context);
              _showClearChatDialog();
            },
          ),
          _buildOptionTile(
            icon: Icons.contact_support_outlined,
            title: 'Contact Human Support',
            onTap: () {
              Navigator.pop(context);
              _showSnackBar('Connecting to human support...');

              // Simulate connection
              Future.delayed(const Duration(seconds: 2), () {
                _receiveAutomaticMessage(
                    'You\'ve been connected to our human support team. An agent will join the chat shortly. Your position in queue: 2.');
              });
            },
          ),
          _buildOptionTile(
            icon: Icons.help_outline,
            title: 'Help & FAQs',
            onTap: () {
              Navigator.pop(context);
              _showSnackBar('Opening Help Center');
            },
          ),
          _buildOptionTile(
            icon: Icons.star_outline,
            title: 'Rate Our Service',
            onTap: () {
              Navigator.pop(context);
              _showRatingDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text(
            'Are you sure you want to clear all messages? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              _saveMessages();
              Navigator.pop(context);

              // Show welcome message after clearing
              Future.delayed(const Duration(milliseconds: 300), () {
                _receiveAutomaticMessage(_welcomeMessage);
              });
            },
            child: const Text('CLEAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    int _rating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Rate Our Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'How would you rate your experience with our chat support?'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: index < _rating ? Colors.amber : Colors.grey,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar('Thank you for your rating!');
              },
              child: const Text('SUBMIT'),
            ),
          ],
        );
      }),
    );
  }
}
