import 'package:flutter/foundation.dart';
import 'package:flutter_project3/services/user_session.dart';
import 'package:flutter_project3/supabase/supabase_connect.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';

class ProfileService {
  static SupabaseClient get _client => DatabaseConfig.client;

  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = UserSession.getCurrentUserId();
      if (userId == null) {
        print('No authenticated user');
        return null;
      }

      print('Fetching profile for user: $userId');
      final user = await _client
          .from('users')
          .select('user_id, nama, email, created_at, profile_picture')
          .eq('user_id', userId)
          .maybeSingle();

      if (user != null) {
        print(
          'Profile fetched successfully - Picture URL: ${user['profile_picture']}',
        );
      } else {
        print('No user found for ID: $userId');
      }

      return user;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  static Future<String?> uploadProfilePicture(String filePath) async {
    try {
      final userId = UserSession.getCurrentUserId();
      if (userId == null) {
        print('No authenticated user');
        return null;
      }

      await _deleteOldProfilePicture(userId);
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('Uploading mobile file: $fileName');

      final response = await _client.storage
          .from('profile_pictures')
          .upload(
            fileName,
            File(filePath),
            fileOptions: const FileOptions(upsert: true),
          );

      print('Upload response: $response');
      final signedUrl = await _client.storage
          .from('profile_pictures')
          .createSignedUrl(fileName, 60 * 60 * 24 * 365 * 10);

      print('Mobile upload complete - Signed URL: $signedUrl');
      await _client
          .from('users')
          .update({
            'profile_picture': signedUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      print('Database updated with new profile picture URL');
      return signedUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      print('Error details: ${e.toString()}');
      return null;
    }
  }

  static Future<String?> uploadProfilePictureWeb(Uint8List imageBytes) async {
    try {
      final userId = UserSession.getCurrentUserId();
      if (userId == null) {
        print('No authenticated user');
        return null;
      }

      await _deleteOldProfilePicture(userId);
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('Uploading web file: $fileName');

      final response = await _client.storage
          .from('profile_pictures')
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      print('Upload response: $response');
      final signedUrl = await _client.storage
          .from('profile_pictures')
          .createSignedUrl(fileName, 60 * 60 * 24 * 365 * 10);

      print('Web upload complete - Signed URL: $signedUrl');
      await _client
          .from('users')
          .update({
            'profile_picture': signedUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      print('Database updated with new profile picture URL');
      return signedUrl;
    } catch (e) {
      print('Error uploading profile picture for web: $e');
      print('Error details: ${e.toString()}');
      return null;
    }
  }

  static Future<bool> changePassword({required String newPassword}) async {
    try {
      final userId = UserSession.getCurrentUserId();
      if (userId == null) {
        print('No authenticated user');
        return false;
      }

      // Update password directly
      await _client.auth.updateUser(UserAttributes(password: newPassword));

      print('Password updated successfully');
      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  static Future<void> _deleteOldProfilePicture(String userId) async {
    try {
      final currentUser = await _client
          .from('users')
          .select('profile_picture')
          .eq('user_id', userId)
          .maybeSingle();

      if (currentUser?['profile_picture'] != null) {
        final oldUrl = currentUser!['profile_picture'] as String;
        if (oldUrl.isNotEmpty && oldUrl.contains('profile_pictures')) {
          String? fileName;
          if (oldUrl.contains('/object/public/profile_pictures/')) {
            final parts = oldUrl.split('/object/public/profile_pictures/');
            if (parts.length > 1) {
              fileName = parts[1].split('?').first;
            }
          } else if (oldUrl.contains('/object/sign/profile_pictures/')) {
            final parts = oldUrl.split('/object/sign/profile_pictures/');
            if (parts.length > 1) {
              fileName = parts[1].split('?').first;
            }
          } else if (oldUrl.contains('profile_')) {
            final uri = Uri.parse(oldUrl);
            final pathSegments = uri.pathSegments;
            fileName = pathSegments.last;
          }

          if (fileName != null && fileName.isNotEmpty) {
            print('Attempting to delete old file: $fileName');
            try {
              await _client.storage.from('profile_pictures').remove([fileName]);
              print('Old profile picture deleted successfully');
            } catch (deleteError) {
              print('Error deleting old profile picture: $deleteError');
            }
          }
        }
      }
    } catch (e) {
      print('Error checking/deleting old profile picture: $e');
    }
  }

  static Future<bool> updateUserProfile({
    required String nama,
    String? profilePictureUrl,
  }) async {
    try {
      final userId = UserSession.getCurrentUserId();
      if (userId == null) {
        print('No authenticated user');
        return false;
      }

      final updates = {
        'nama': nama,
        'updated_at': DateTime.now().toIso8601String(),
        if (profilePictureUrl != null) 'profile_picture': profilePictureUrl,
      };

      print('Updating user profile with: $updates');
      await _client.from('users').update(updates).eq('user_id', userId);
      print('User profile updated successfully');
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  static Future<void> refreshUserSession() async {
    try {
      final updatedUser = await getUserProfile();
      if (updatedUser != null) {
        UserSession.setCurrentUser(updatedUser);
        print('User session refreshed successfully');
      }
    } catch (e) {
      print('Error refreshing user session: $e');
    }
  }
}
