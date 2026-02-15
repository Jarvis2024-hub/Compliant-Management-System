import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _roleKey = 'user_role';

  /* ================= TOKEN ================= */

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    // Debug log (safe – does not expose in production builds)
    developer.log('JWT SAVED SUCCESSFULLY');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    developer.log(
      token != null ? 'JWT FOUND IN STORAGE' : 'JWT NOT FOUND IN STORAGE',
    );

    return token;
  }

  /// 🔑 THIS IS THE IMPORTANT PART
  /// Returns Authorization header for protected APIs
  Future<Map<String, String>> getAuthHeader() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authorization token missing');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /* ================= USER ================= */

  Future<void> saveUser(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userData);
  }

  Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  /* ================= ROLE ================= */

  Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  /* ================= SESSION ================= */

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    developer.log('STORAGE CLEARED');
  }
}
