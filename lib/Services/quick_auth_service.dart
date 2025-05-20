import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuickAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in anonymously
  Future<AuthResponse> signInAnonymously() async {
    try {
      // First check if we already have a session
      final session = _supabase.auth.currentSession;
      if (session != null) {
        debugPrint('Already have an active session');
        return AuthResponse(session: session, user: _supabase.auth.currentUser);
      }

      // If no session exists, sign in anonymously
      final response = await _supabase.auth.signInWithPassword(
        // Use your predefined test account credentials
        email: 'test@gmail.com',
        password: '123456', // Use a strong password in production
      );

      debugPrint(
          'Signed in anonymously/with test account: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      throw Exception('Anonymous sign in failed: $e');
    }
  }

  // Check if user is authenticated and sign in if not
  Future<bool> ensureAuthenticated() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        debugPrint('User already authenticated: ${user.id}');
        return true;
      }

      // No user, try to sign in anonymously
      final response = await signInAnonymously();
      final success = response.user != null;

      debugPrint('Authentication ${success ? 'successful' : 'failed'}');
      return success;
    } catch (e) {
      debugPrint('Error ensuring authentication: $e');
      return false;
    }
  }
}
