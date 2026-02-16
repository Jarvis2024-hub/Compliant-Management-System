class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? specialization;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.specialization,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      email: json['email'],
      role: json['role'],
      specialization: json['specialization'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'specialization': specialization,
    };
  }

  bool isAdmin() => role == 'admin';
  bool isUser() => role == 'user';
  bool isEngineer() => role == 'engineer';
}