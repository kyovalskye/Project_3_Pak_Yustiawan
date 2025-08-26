import 'package:flutter/material.dart';

class UserSession {
  static Map<String, dynamic>? _currentUser;

  // Add callback for UI updates
  static VoidCallback? _onUserUpdated;

  static void setCurrentUser(Map<String, dynamic>? user) {
    _currentUser = user;
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

  static void clearSession() {
    _currentUser = null;
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
}
