import 'package:flutter_project3/supabase/supabase_connect.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseService {
  static get _client => DatabaseConfig.client;

  // Hash password menggunakan SHA-256
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Registrasi user baru
  static Future<Map<String, dynamic>> registerUser({
    required String nama,
    required String password,
  }) async {
    try {
      // Cek apakah user sudah ada
      final existingUser = await _client
          .from('user')
          .select('id, nama')
          .eq('nama', nama)
          .maybeSingle();

      if (existingUser != null) {
        return {
          'success': false,
          'message': 'Nama pengguna sudah digunakan',
        };
      }

      // Hash password
      final hashedPassword = _hashPassword(password);

      // Insert user baru
      final response = await _client.from('user').insert({
        'nama': nama,
        'password': hashedPassword,
        'created_at': DateTime.now().toIso8601String(),
      }).select('id, nama, created_at').single();

      return {
        'success': true,
        'message': 'Akun berhasil dibuat',
        'user': response,
      };
    } catch (e) {
      print('Error registering user: $e');
      
      // Handle specific errors
      if (e.toString().contains('duplicate key')) {
        return {
          'success': false,
          'message': 'Nama pengguna sudah digunakan',
        };
      } else if (e.toString().contains('relation') && e.toString().contains('does not exist')) {
        return {
          'success': false,
          'message': 'Tabel database tidak ditemukan',
        };
      }
      
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat membuat akun: ${e.toString()}',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> loginUser({
    required String nama,
    required String password,
  }) async {
    try {
      // Hash password untuk pencocokan
      final hashedPassword = _hashPassword(password);

      // Cari user dengan nama dan password yang cocok
      final user = await _client
          .from('user')
          .select('id, nama, created_at')
          .eq('nama', nama)
          .eq('password', hashedPassword)
          .maybeSingle();

      if (user == null) {
        return {
          'success': false,
          'message': 'Nama pengguna atau password salah',
        };
      }

      return {
        'success': true,
        'message': 'Login berhasil',
        'user': user,
      };
    } catch (e) {
      print('Error logging in user: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat login: ${e.toString()}',
      };
    }
  }

  // Get user by ID
  static Future<Map<String, dynamic>?> getUserById(int id) async {
    try {
      final user = await _client
          .from('user')
          .select('id, nama, created_at')
          .eq('id', id)
          .maybeSingle();

      return user;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
}