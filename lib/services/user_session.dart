// services/user_session.dart
class UserSession {
  static Map<String, dynamic>? _currentUser;

  // Set current user
  static void setCurrentUser(Map<String, dynamic> user) {
    _currentUser = user;
  }

  // Get current user
  static Map<String, dynamic>? getCurrentUser() {
    return _currentUser;
  }

  // Get current user name
  static String? getCurrentUserName() {
    return _currentUser?['nama'];
  }

  // Get current user ID
  static int? getCurrentUserId() {
    return _currentUser?['id'];
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _currentUser != null;
  }

  // Clear session (logout)
  static void clearSession() {
    _currentUser = null;
  }
}
