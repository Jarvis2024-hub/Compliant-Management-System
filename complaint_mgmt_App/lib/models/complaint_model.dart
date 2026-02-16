class ComplaintModel {
  final int id;
  final String description;
  final String priority;
  final String status;
  final String categoryName;
  final String createdAt;
  final String? userName;
  final String? userEmail;
  final String? adminResponse;
  final String? responseDate;
  final String? engineerName;
  final String? engineerResponse;

  ComplaintModel({
    required this.id,
    required this.description,
    required this.priority,
    required this.status,
    required this.categoryName,
    required this.createdAt,
    this.userName,
    this.userEmail,
    this.adminResponse,
    this.responseDate,
    this.engineerName,
    this.engineerResponse,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: int.parse(json['id'].toString()),
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Low',
      status: json['status'] ?? 'Pending',
      categoryName: json['category_name'] ?? '',
      createdAt: json['created_at'] ?? '',
      userName: json['user_name'],
      userEmail: json['user_email'],
      adminResponse: json['admin_response'],
      responseDate: json['response_date'],
      engineerName: json['engineer_name'],
      engineerResponse: json['engineer_response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'priority': priority,
      'status': status,
      'category_name': categoryName,
      'created_at': createdAt,
      'user_name': userName,
      'user_email': userEmail,
      'admin_response': adminResponse,
      'response_date': responseDate,
      'engineer_name': engineerName,
      'engineer_response': engineerResponse,
    };
  }

  bool isPending() => status == 'Pending';
  bool isInProgress() => status == 'In Progress';
  bool isResolved() => status == 'Resolved';
}