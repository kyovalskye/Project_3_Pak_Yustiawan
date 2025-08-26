// user_services.dart
import 'package:flutter_project3/supabase/supabase_connect.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class DatabaseService {
  static get _client => DatabaseConfig.client;

  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<Map<String, dynamic>> registerUser({
    required String nama,
    required String email,
    required String password,
  }) async {
    try {
      final existingUser = await _client
          .from('users')
          .select('user_id, email')
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        return {'success': false, 'message': 'Email sudah digunakan'};
      }

      final hashedPassword = _hashPassword(password);

      final response = await _client
          .from('users')
          .insert({
            'nama': nama,
            'email': email,
            'password': hashedPassword,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('user_id, nama, email, created_at')
          .single();

      return {
        'success': true,
        'message': 'Akun berhasil dibuat',
        'user': response,
      };
    } catch (e) {
      print('Error registering user: $e');
      if (e.toString().contains('duplicate key')) {
        return {'success': false, 'message': 'Email sudah digunakan'};
      } else if (e.toString().contains('relation') &&
          e.toString().contains('does not exist')) {
        return {'success': false, 'message': 'Tabel database tidak ditemukan'};
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat membuat akun: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final hashedPassword = _hashPassword(password);

      final user = await _client
          .from('users')
          .select('user_id, nama, email, created_at, profile_picture')
          .eq('email', email)
          .eq('password', hashedPassword)
          .maybeSingle();

      if (user == null) {
        return {'success': false, 'message': 'Email atau password salah'};
      }

      return {'success': true, 'message': 'Login berhasil', 'user': user};
    } catch (e) {
      print('Error logging in user: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat login: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final user = await _client
          .from('users')
          .select('user_id, nama, email, created_at, profile_picture')
          .eq('user_id', userId)
          .maybeSingle();

      return user;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  static Future<String?> uploadProfilePicture(
    String userId,
    String filePath,
  ) async {
    try {
      final fileName =
          '$userId/profile_picture_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage
          .from('profile_pictures')
          .upload(
            fileName,
            File(filePath),
            fileOptions: const FileOptions(upsert: true),
          );

      final signedUrl = await _client.storage
          .from('profile_pictures')
          .createSignedUrl(
            fileName,
            60 * 60 * 24 * 365, // URL berlaku selama 1 tahun
          );

      await _client
          .from('users')
          .update({'profile_picture': signedUrl})
          .eq('user_id', userId);

      return signedUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  static Future<bool> updateUserProfile({
    required String userId,
    required String nama,
    String? profilePictureUrl,
  }) async {
    try {
      final updates = {
        'nama': nama,
        'updated_at': DateTime.now().toIso8601String(),
        if (profilePictureUrl != null) 'profile_picture': profilePictureUrl,
      };

      await _client.from('users').update(updates).eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
}
