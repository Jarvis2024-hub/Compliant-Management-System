import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/response_model.dart';
import 'storage_service.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);
  final StorageService _storage = StorageService();

  /// Automatically combines user-provided headers with the JWT Authorization header.
  Future<Map<String, String>> _getHeaders(Map<String, String>? customHeaders) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Try to add the Bearer token from storage
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  /* ===================== GET ===================== */
  Future<ApiResponse> get(
      String url, {
        Map<String, String>? headers,
      }) async {
    try {
      final finalHeaders = await _getHeaders(headers);
      final response = await http
          .get(
        Uri.parse(url),
        headers: finalHeaders,
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  /* ===================== POST ===================== */
  Future<ApiResponse> post(
      String url,
      dynamic body, {
        Map<String, String>? headers,
      }) async {
    try {
      final finalHeaders = await _getHeaders(headers);
      final response = await http
          .post(
        Uri.parse(url),
        headers: finalHeaders,
        body: json.encode(body),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  /* ===================== PUT ===================== */
  Future<ApiResponse> put(
      String url,
      dynamic body, {
        Map<String, String>? headers,
      }) async {
    try {
      final finalHeaders = await _getHeaders(headers);
      final response = await http
          .put(
        Uri.parse(url),
        headers: finalHeaders,
        body: json.encode(body),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  /* ===================== RESPONSE HANDLER ===================== */
  Future<ApiResponse> _handleResponse(http.Response response) async {
    if (response.body.isEmpty) {
      return ApiResponse(success: false, message: 'Empty response from server');
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

      if (response.statusCode == 401) {
        // Unauthorized - Token likely expired or invalid
        await _storage.clearAll();
        return ApiResponse(
          success: false,
          message: decoded['message'] ?? 'Unauthorized. Please login again.',
        );
      }

      return ApiResponse(
        success: false,
        message: decoded['message'] ?? 'Server error (${response.statusCode})',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to parse server response. Check backend.',
      );
    }
  }
}
