import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserDisplayName = 'user_display_name';
  static const String _keyUserPhotoUrl = 'user_photo_url';
  static const String _keyAuthProvider = 'auth_provider';

  static Future<void> saveUserData({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
    required String authProvider,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyAuthProvider, authProvider);
    
    if (displayName != null) {
      await prefs.setString(_keyUserDisplayName, displayName);
    }
    if (photoUrl != null) {
      await prefs.setString(_keyUserPhotoUrl, photoUrl);
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    
    if (!isLoggedIn) return null;

    return {
      'userId': prefs.getString(_keyUserId) ?? '',
      'email': prefs.getString(_keyUserEmail) ?? '',
      'displayName': prefs.getString(_keyUserDisplayName),
      'photoUrl': prefs.getString(_keyUserPhotoUrl),
      'authProvider': prefs.getString(_keyAuthProvider) ?? 'email',
    };
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserDisplayName);
    await prefs.remove(_keyUserPhotoUrl);
    await prefs.remove(_keyAuthProvider);
  }
}

