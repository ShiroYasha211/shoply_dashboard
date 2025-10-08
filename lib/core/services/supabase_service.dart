import 'package:dashboard_test/core/constants/supabase_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase client is not initialized. Call initialize() first.',
      );
    }
    return _client!;
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  static bool get isInitialized => _client != null;
}
