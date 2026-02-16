import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;

import '../config/api_config.dart';
import 'storage_service.dart';
import '../models/user_model.dart';
import '../models/response_model.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final StorageService _storage = StorageService();
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      try {
        await _googleSignIn.initialize(
          serverClientId: '78996867088-kdvojk833qssfj8i7ns9vv780h96eb7a.apps.googleusercontent.com',
        );
        _isInitialized = true;
      } catch (e) {
        developer.log('Initialization error: $e');
      }
    }
  }

  // Email & Password Login
  Future<ApiResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      return _processAuthResponse(response, null);
    } on TimeoutException {
      return ApiResponse(success: false, message: 'Connection Timeout. Is your backend running?');
    } catch (e) {
      return ApiResponse(success: false, message: 'Login error: $e');
    }
  }

  // Register
  Future<ApiResponse> register(String name, String email, String password, String role, {String? specialization}) async {
    try {
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        if (specialization != null) 'specialization': specialization,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

       final result = _handleBasicResponse(response);
       return result;

    } on TimeoutException {
      return ApiResponse(success: false, message: 'Connection Timeout');
    } catch (e) {
      return ApiResponse(success: false, message: 'Registration error: $e');
    }
  }

  // Google Sign-In
  Future<ApiResponse> signInWithGoogle(String role) async {
    try {
      await _ensureInitialized();
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.authenticate(
          scopeHint: ['email', 'profile'],
        );
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          return ApiResponse(success: false, message: 'Google sign-in cancelled');
        }
        return ApiResponse(success: false, message: 'Google error: ${e.description}');
      }
      
      if(googleUser == null) {
          return ApiResponse(success: false, message: 'Google sign-in cancelled');
      }

      try {
        final response = await http.post(
          Uri.parse(ApiConfig.googleAuth),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'google_id': googleUser.id,
            'email': googleUser.email,
            'name': googleUser.displayName ?? 'User',
            'role': role,
          }),
        ).timeout(const Duration(seconds: 30));

        return _processAuthResponse(response, role);

      } on TimeoutException {
        return ApiResponse(success: false, message: 'Connection Timeout. Is your backend running?');
      } on Exception catch (e) {
        return ApiResponse(success: false, message: 'Network error: $e');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Sign-in error: $e');
    }
  }

  // Helper to process login/google auth response
  Future<ApiResponse> _processAuthResponse(http.Response response, String? role) async {
    // DEBUG: Print the raw response body
    developer.log('Backend Response Body: ${response.body}');

    if (response.body.isEmpty) {
      return ApiResponse(success: false, message: 'Server returned an empty response.');
    }

    final dynamic decodedData;
    try {
      decodedData = json.decode(response.body);
    } catch (e) {
      return ApiResponse(
        success: false, 
        message: 'Server did not return valid JSON. Response start: ${response.body.substring(0, response.body.length > 50 ? 50 : response.body.length)}...'
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decodedData['success'] == true) {
        // Success - Save Token
        developer.log('TOKEN SAVED: ${decodedData['data']['token']}');
        await _storage.saveToken(decodedData['data']['token']);
        await _storage.saveUser(json.encode(decodedData['data']['user']));
        
        // If role wasn't passed (email login), get it from response
        final String userRole = role ?? decodedData['data']['user']['role'];
        await _storage.saveRole(userRole);
        
        return ApiResponse(success: true, message: decodedData['message'], data: decodedData['data']);
      } else {
        // Business logic failure (e.g. Pending)
         return ApiResponse(success: false, message: decodedData['message'] ?? 'Login failed');
      }
    } else if (response.statusCode == 403) {
      // Forbidden - likely pending
       return ApiResponse(success: false, message: decodedData['message'] ?? 'Account pending approval');
    }

    return ApiResponse(success: false, message: 'Server Error (${response.statusCode}): ${decodedData['message'] ?? 'Unknown error'}');
  }

  ApiResponse _handleBasicResponse(http.Response response) {
     if (response.body.isEmpty) {
      return ApiResponse(success: false, message: 'Server returned an empty response.');
    }
    
    try {
      final decoded = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
         return ApiResponse(
          success: decoded['success'] ?? false,
          message: decoded['message'] ?? '',
          data: decoded['data'],
        );
      }
      return ApiResponse(success: false, message: decoded['message'] ?? 'Error ${response.statusCode}');
    } catch(e) {
       return ApiResponse(success: false, message: 'Invalid JSON response from server');
    }
  }


  Future<UserModel?> getCurrentUser() async {
    try {
      final userJson = await _storage.getUser();
      return userJson != null ? UserModel.fromJson(json.decode(userJson)) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }
}
