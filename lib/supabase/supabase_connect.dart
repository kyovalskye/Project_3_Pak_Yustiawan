import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: "../../.env");

    await Supabase.initialize(
      url: dotenv.env['API_URL'] ?? '',
      anonKey: dotenv.env['API_KEY'] ?? '',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
