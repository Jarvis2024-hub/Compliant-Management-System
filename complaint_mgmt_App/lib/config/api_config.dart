class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/backend';
  
  // Auth
  static const String register = '$baseUrl/auth/register.php';
  static const String login = '$baseUrl/auth/login.php';
  static const String googleAuth = '$baseUrl/auth/google_auth.php';
  
  // Complaints
  static const String categoriesList = '$baseUrl/api/categories/list.php';
  static const String createComplaint = '$baseUrl/api/complaints/create.php';
  static const String myComplaints = '$baseUrl/api/complaints/list.php';
  static const String complaintDetails = '$baseUrl/api/complaints/details.php';
  static const String updateStatus = '$baseUrl/api/complaints/update_status.php';

  // Admin & Assignment
  static const String allComplaints = '$baseUrl/api/admin/all_complaints.php';
  static const String pendingUsers = '$baseUrl/api/admin/pending_users.php';
  static const String approveUser = '$baseUrl/api/admin/approve_user.php';
  static const String rejectUser = '$baseUrl/api/admin/reject_user.php';
  static const String addResponse = '$baseUrl/api/admin/add_response.php';
  static const String assignEngineer = '$baseUrl/api/admin/assign_engineer.php';
  static const String engineersByCategory = '$baseUrl/api/admin/engineers_list.php';
}
