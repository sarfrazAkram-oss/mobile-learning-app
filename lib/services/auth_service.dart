import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userEmailKey = 'userEmail';

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      // Return false on any error to ensure safe fallback
      return false;
    }
  }

  /// Save login state
  static Future<bool> saveLoginState(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool(_isLoggedInKey, true),
        prefs.setString(_userEmailKey, email),
      ]);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear login state (logout)
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_isLoggedInKey),
        prefs.remove(_userEmailKey),
      ]);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get stored user email
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      return null;
    }
  }

  /// Get the last used email for login
  static Future<String?> getLastLoginEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      return null;
    }
  }

  /// Mock login function - replace with real implementation
  static Future<bool> login(String email, String password) async {
    try {
      // Validate inputs
      if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
        return false;
      }
      if (password.isEmpty || password.length < 6) {
        return false;
      }

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Save login state on success
      return await saveLoginState(email);
    } catch (e) {
      return false;
    }
  }
}
