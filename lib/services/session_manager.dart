import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {

  static const _keyToken        = 'auth_token';
  static const _keyCookie       = 'ci_session';
  static const _keyEmail        = 'saved_email';
  static const _keyPassword     = 'saved_password';
  static const _keySaveCreds    = 'save_credentials';
  static const _keySessionExpiry = 'session_expiry';

  // Session lasts 7 days 
  static const _sessionDurationDays = 7;

  //Save session after successful login 
  static Future<void> saveSession({
    required String token,
    String? sessionCookie,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    if (sessionCookie != null) {
      await prefs.setString(_keyCookie, sessionCookie);
    }
    final expiry = DateTime.now()
        .add(const Duration(days: _sessionDurationDays))
        .millisecondsSinceEpoch;
    await prefs.setInt(_keySessionExpiry, expiry);
    print("SESSION SAVED — expires in $_sessionDurationDays days");
  }

  // Load session (returns null if expired or missing)
  static Future<Map<String, String?>?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token  = prefs.getString(_keyToken);
    final expiry = prefs.getInt(_keySessionExpiry);

    if (token == null || token.isEmpty) return null;

    if (expiry != null) {
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry);
      if (DateTime.now().isAfter(expiryDate)) {
        print("SESSION EXPIRED — clearing");
        await clearSession();
        return null;
      }
    }

    return {
      'token':         token,
      'sessionCookie': prefs.getString(_keyCookie),
    };
  }

  //Clear session on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyCookie);
    await prefs.remove(_keySessionExpiry);
    print("SESSION CLEARED");
  }

  //Save credentials for autofill
  static Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    await prefs.setBool(_keySaveCreds, true);
    print("CREDENTIALS SAVED");
  }

  static Future<Map<String, String?>?> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final save = prefs.getBool(_keySaveCreds) ?? false;
    if (!save) return null;
    return {
      'email':    prefs.getString(_keyEmail),
      'password': prefs.getString(_keyPassword),
    };
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.setBool(_keySaveCreds, false);
  }

  static Future<bool> get hasSavedCredentials async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySaveCreds) ?? false;
  }
}