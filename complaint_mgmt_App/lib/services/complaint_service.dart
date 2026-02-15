import '../config/api_config.dart';
import '../models/response_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class ComplaintService {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  /* ===================== AUTH HEADER ===================== */

  Future<Map<String, String>> _authHeader() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authorization token missing');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /* ===================== CATEGORIES ===================== */

  Future<ApiResponse> getCategories() async {
    final headers = await _authHeader();
    return await _apiService.get(
      ApiConfig.categoriesList,
      headers: headers,
    );
  }

  /* ===================== USER ===================== */

  Future<ApiResponse> createComplaint({
    required int categoryId,
    required String description,
    required String priority,
  }) async {
    final headers = await _authHeader();
    return await _apiService.post(
      ApiConfig.createComplaint,
      {
        'category_id': categoryId,
        'description': description,
        'priority': priority,
      },
      headers: headers,
    );
  }

  Future<ApiResponse> getMyComplaints() async {
    final headers = await _authHeader();
    return await _apiService.get(
      ApiConfig.myComplaints,
      headers: headers,
    );
  }

  Future<ApiResponse> getComplaintDetails(int complaintId) async {
    final headers = await _authHeader();
    return await _apiService.get(
      '${ApiConfig.complaintDetails}?id=$complaintId',
      headers: headers,
    );
  }

  /* ===================== ADMIN ===================== */

  Future<ApiResponse> getAllComplaints({
    String? status,
    String? priority,
  }) async {
    final headers = await _authHeader();
    String url = ApiConfig.allComplaints;
    final params = <String>[];
    if (status != null && status.isNotEmpty) params.add('status=$status');
    if (priority != null && priority.isNotEmpty) params.add('priority=$priority');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    return await _apiService.get(url, headers: headers);
  }

  Future<ApiResponse> updateComplaintStatus({
    required int complaintId,
    required String status,
  }) async {
    final headers = await _authHeader();

    // Changed from .post to .put to match typical "update" APIs
    // If your backend specifically requires POST, please let me know.
    return await _apiService.put(
      ApiConfig.updateStatus,
      {
        'complaint_id': complaintId,
        'status': status,
      },
      headers: headers,
    );
  }

  Future<ApiResponse> addAdminResponse({
    required int complaintId,
    required String response,
  }) async {
    final headers = await _authHeader();
    return await _apiService.post(
      ApiConfig.addResponse,
      {
        'complaint_id': complaintId,
        'response': response,
      },
      headers: headers,
    );
  }

  Future<ApiResponse> getAssignedComplaints() async {
    final headers = await _authHeader();
    return await _apiService.get(
      '${ApiConfig.baseUrl}/api/complaints/my_assigned.php',
      headers: headers,
    );
  }
}
