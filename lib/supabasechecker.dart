import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseChecker {
  static bool isInitialized() {
    try {
      // This will throw an exception if Supabase is not initialized
      Supabase.instance.client;
      return true;
    } catch (e) {
      return false;
    }
  }
}
