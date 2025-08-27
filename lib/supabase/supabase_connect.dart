import 'package:flutter_project3/services/user_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");

    await Supabase.initialize(
      url: dotenv.env['API_URL'] ?? '',
      anonKey: dotenv.env['API_KEY'] ?? '',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<bool> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        final userData = await client
            .from('users')
            .select('user_id, nama, email, created_at, profile_picture')
            .eq('user_id', response.user!.id)
            .maybeSingle();
        if (userData != null) {
          UserSession.setCurrentUser(userData);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  static Future<bool> signUp({
    required String nama,
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        final userData = await client
            .from('users')
            .insert({
              'user_id': response.user!.id,
              'nama': nama,
              'email': email,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select('user_id, nama, email, created_at, profile_picture')
            .single();
        UserSession.setCurrentUser(userData);
        return true;
      }
      return false;
    } catch (e) {
      print('Error signing up: $e');
      return false;
    }
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
    UserSession.clearSession();
  }
}
