// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';

class AppwriterInitializer {
  static bool _isInitialized = false;
  
  static var AppwriteClient;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
       await AppwriteClient.initialize(
    endpoint: 'https://cloud.appwrite.io/v1',
    projectId: 'YOUR_PROJECT_ID', // Replace with your actual Appwrite project ID
  );
      _isInitialized = true;
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      _isInitialized = false;
    }
  }
}
