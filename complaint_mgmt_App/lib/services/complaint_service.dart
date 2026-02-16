import '../config/api_config.dart';
import '../models/response_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class ComplaintService {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  /* ===================== CATEGORIES ===================== */

  Future<ApiResponse> getCategories() async {
    return await _apiService.get(ApiConfig.categoriesList);
  }

  /* ===================== USER ===================== */

  Future<ApiResponse> createComplaint({
    required int categoryId,
    required String description,
    required String priority,
  }) async {
    return await _apiService.post(
      ApiConfig.createComplaint,
      {
        'category_id': categoryId,
        'description': description,
        'priority': priority,
      },
    );
  }

  Future<ApiResponse> getMyComplaints() async {
    return await _apiService.get(ApiConfig.myComplaints);
  }

  Future<ApiResponse> getComplaintDetails(int complaintId) async {
    return await _apiService.get('${ApiConfig.complaintDetails}?id=$complaintId');
  }

  /* ===================== ADMIN ===================== */

  Future<ApiResponse> getAllComplaints({
    String? status,
    String? priority,
  }) async {
    String url = ApiConfig.allComplaints;
    final params = <String>[];
    if (status != null && status.isNotEmpty) params.add('status=$status');
    if (priority != null && priority.isNotEmpty) params.add('priority=$priority');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    return await _apiService.get(url);
  }

  // 🛠 NEW: Manual Assignment API Call
  Future<ApiResponse> assignEngineer({
    required int complaintId,
    required int engineerId,
  }) async {
    return await _apiService.post(
      '${ApiConfig.baseUrl}/api/admin/assign_engineer.php',
      {
        'complaint_id': complaintId,
        'engineer_id': engineerId,
      },
    );
  }

  // 🛠 NEW: Fetch available engineers for a category
  Future<ApiResponse> getEngineersByCategory(String categoryName) async {
    return await _apiService.get(
      '${ApiConfig.baseUrl}/api/admin/engineers_list.php?category=$categoryName',
    );
  }

  Future<ApiResponse> updateComplaintStatus({
    required int complaintId,
    required String status,
  }) async {
    return await _apiService.put(
      ApiConfig.updateStatus,
      {
        'complaint_id': complaintId,
        'status': status,
      },
    );
  }

  Future<ApiResponse> addAdminResponse({
    required int complaintId,
    required String response,
  }) async {
    return await _apiService.post(
      ApiConfig.addResponse,
      {
        'complaint_id': complaintId,
        'response': response,
      },
    );
  }

  /* ===================== ENGINEER ===================== */

  Future<ApiResponse> getAssignedComplaints() async {
    return await _apiService.get('${ApiConfig.baseUrl}/api/complaints/my_assigned.php');
  }
}
