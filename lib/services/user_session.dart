import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserSession {
  static Map<String, dynamic>? _currentUser;
  static VoidCallback? _onUserUpdated;
  static const String _userKey = 'current_user';

  // Load user data from SharedPreferences
  static Future<void> loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        _currentUser = json.decode(userJson) as Map<String, dynamic>;
        print('User loaded from SharedPreferences: ${_currentUser?['nama']}');
      }
    } catch (e) {
      print('Error loading user from SharedPreferences: $e');
    }
  }

  // Save user data to SharedPreferences
  static Future<void> _saveUserToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString(_userKey, json.encode(_currentUser));
        print('User saved to SharedPreferences: ${_currentUser?['nama']}');
      } else {
        await prefs.remove(_userKey);
        print('User data removed from SharedPreferences');
      }
    } catch (e) {
      print('Error saving user to SharedPreferences: $e');
    }
  }

  static Future<void> setCurrentUser(Map<String, dynamic>? user) async {
    _currentUser = user;
    await _saveUserToPrefs();
    // Notify listeners when user data is updated
    if (_onUserUpdated != null) {
      _onUserUpdated!();
    }
  }

  static Map<String, dynamic>? getCurrentUser() {
    return _currentUser;
  }

  static String? getCurrentUserName() {
    return _currentUser?['nama'] as String?;
  }

  static String? getCurrentUserId() {
    return _currentUser?['user_id'] as String?;
  }

  static String? getCurrentUserProfilePicture() {
    return _currentUser?['profile_picture'] as String?;
  }

  static bool isLoggedIn() {
    return _currentUser != null;
  }

  static Future<void> clearSession() async {
    _currentUser = null;
    await _saveUserToPrefs();
    if (_onUserUpdated != null) {
      _onUserUpdated!();
    }
  }

  // Method to set callback for UI updates
  static void setUpdateCallback(VoidCallback callback) {
    _onUserUpdated = callback;
  }

  // Method to clear callback
  static void clearUpdateCallback() {
    _onUserUpdated = null;
  }

  // Method to force UI update
  static void notifyUpdate() {
    if (_onUserUpdated != null) {
      _onUserUpdated!();
    }
  }

  // Method to update specific user field
  static Future<void> updateUserField(String key, dynamic value) async {
    if (_currentUser != null) {
      _currentUser![key] = value;
      await _saveUserToPrefs();
      if (_onUserUpdated != null) {
        _onUserUpdated!();
      }
    }
  }
}
