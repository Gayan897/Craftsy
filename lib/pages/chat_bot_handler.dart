import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatBotHandler {
  // Predefined responses for demo purposes
  final List<String> _greetings = [
    'Hello!',
    'Hi there!',
    'Welcome to Craft!',
    'Hey! How can I help you today?',
  ];

  final List<String> _farewells = [
    'Thank you for chatting with us!',
    'Have a great day!',
    'Goodbye! Feel free to reach out anytime.',
    'Thanks for visiting Craft. Hope to see you again soon!',
  ];

  final Map<String, List<String>> _responses = {
    'shipping': [
      'We offer standard shipping (3-5 days) and express shipping (1-2 days).',
      'Shipping costs depend on your location and the size of your order.',
      'For orders over Rs.1500, we offer free standard shipping!',
    ],
    'return': [
      'We have a 30-day return policy for most items.',
      'To initiate a return, please contact our support team with your order details.',
      'Please note that customized items cannot be returned unless defective.',
    ],
    'payment': [
      'We accept credit/debit cards, mobile payments, and cash on delivery.',
      'All payments are secure and encrypted.',
      'For orders above Rs.5000, we offer installment options too!',
    ],
    'material': [
      'Our products are made from high-quality, eco-friendly materials.',
      'Each product page lists detailed material information.',
      'We source most of our materials locally to support our community.',
    ],
    'custom': [
      'Yes, we offer customization for many products!',
      'Please let us know your specific requirements, and our artisans will create something special for you.',
      'Customization usually adds 3-5 days to the delivery time.',
    ],
    'order': [
      'You can place an order by selecting a product, clicking "View Details", and then tapping the "Add to Cart" button.',
      'Once you\'ve added all desired items to your cart, proceed to checkout and follow the instructions.',
      'After placing an order, you\'ll receive a confirmation email with tracking details.',
    ],
  };

  // Get a response based on user message
  Future<String> getResponse(String userMessage) async {
    // For demo purposes, let's use local processing
    // In a real app, you might want to connect to a proper NLP service

    // Convert to lowercase for easier keyword matching
    final lowerUserMsg = userMessage.toLowerCase();

    // Track user interaction for personalization
    await _trackInteraction(lowerUserMsg);

    // Check for greetings
    if (_isGreeting(lowerUserMsg)) {
      return _getRandomResponse(_greetings);
    }

    // Check for farewells
    if (_isFarewell(lowerUserMsg)) {
      return _getRandomResponse(_farewells);
    }

    // Check for keywords in the message
    for (final entry in _responses.entries) {
      if (lowerUserMsg.contains(entry.key)) {
        return _getRandomResponse(entry.value);
      }
    }

    // Check for product inquiries (this would connect to your product database in a real app)
    if (lowerUserMsg.contains('basket') || lowerUserMsg.contains('pot')) {
      return 'We have several handmade items in that category. Would you like me to show you our top-rated products?';
    }

    // Default response if no keywords matched
    return 'Thank you for your message! Our team will get back to you shortly. Is there anything specific about our handmade crafts that you\'d like to know?';
  }

  // Check if message is a greeting
  bool _isGreeting(String message) {
    final greetingWords = [
      'hello',
      'hi',
      'hey',
      'greetings',
      'good morning',
      'good afternoon',
      'good evening'
    ];
    return greetingWords.any((word) => message.contains(word));
  }

  // Check if message is a farewell
  bool _isFarewell(String message) {
    final farewellWords = [
      'bye',
      'goodbye',
      'see you',
      'farewell',
      'thanks',
      'thank you'
    ];
    return farewellWords.any((word) => message.contains(word));
  }

  // Get a random response from a list
  String _getRandomResponse(List<String> responses) {
    final random = Random();
    return responses[random.nextInt(responses.length)];
  }

  // Track user interaction for personalization
  Future<void> _trackInteraction(String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> interactionHistory =
          prefs.getStringList('chat_interactions') ?? [];

      // Limit history length to prevent excessive storage
      if (interactionHistory.length >= 20) {
        interactionHistory.removeAt(0);
      }

      interactionHistory.add(message);
      await prefs.setStringList('chat_interactions', interactionHistory);
    } catch (e) {
      debugPrint('Error tracking chat interaction: $e');
    }
  }

  // For advanced implementation: connect to a proper NLP service
  // This is just a placeholder for demonstration
  // ignore: unused_element
  Future<String> _getAdvancedResponse(String message) async {
    try {
      // This would be your API endpoint in a real implementation
      final apiUrl = Uri.parse('https://your-nlp-service.com/api/chat');

      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'Sorry, I couldn\'t understand that.';
      } else {
        return 'Sorry, I\'m having trouble connecting to my knowledge base.';
      }
    } catch (e) {
      return 'Sorry, I\'m currently unavailable. Please try again later.';
    }
  }

  // Get suggested quick replies based on context
  List<String> getSuggestedReplies(List<String> interactionHistory) {
    // In a real app, you'd use the interaction history to generate contextual suggestions
    // For demo, we'll return standard questions
    return [
      'How do I place an order?',
      'What are your shipping options?',
      'Do you offer customization?',
      'What payment methods do you accept?',
    ];
  }
}
