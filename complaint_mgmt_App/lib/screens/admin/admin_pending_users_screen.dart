import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';
import '../../config/api_config.dart';

class AdminPendingUsersScreen extends StatefulWidget {
  const AdminPendingUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminPendingUsersScreen> createState() => _AdminPendingUsersScreenState();
}

class _AdminPendingUsersScreenState extends State<AdminPendingUsersScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _pendingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    setState(() => _isLoading = true);
    final response = await _apiService.get(ApiConfig.pendingUsers); // Need to add this to ApiConfig if not present

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success) {
          _pendingUsers = response.data;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message), backgroundColor: AppColors.error),
          );
        }
      });
    }
  }

  Future<void> _handleAction(int userId, bool approve) async {
    final url = approve ? ApiConfig.approveUser : ApiConfig.rejectUser; // Need to add to ApiConfig
    
    // Optimistic UI update or loader? Loader is safer.
    // showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    final response = await _apiService.post(url, {'user_id': userId});
    
    // Navigator.pop(context); // Pop loader if used

    if (mounted) {
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'User Approved' : 'User Rejected'),
            backgroundColor: approve ? AppColors.success : AppColors.warning,
          ),
        );
        _loadPendingUsers(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingUsers.isEmpty
              ? const Center(child: Text('No pending users found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingUsers.length,
                  itemBuilder: (context, index) {
                    final user = _pendingUsers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: Icon(
                                    user['role'] == 'engineer' ? Icons.engineering : Icons.admin_panel_settings,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['name'] ?? 'Unknown',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(user['email'] ?? '', style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    user['role'].toString().toUpperCase(),
                                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            if (user['role'] == 'engineer' && user['specialization'] != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.category, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text('Specialization: ${user['specialization']}'),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _handleAction(int.parse(user['id'].toString()), false),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(color: AppColors.error),
                                    ),
                                    child: const Text('Reject'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _handleAction(int.parse(user['id'].toString()), true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                    ),
                                    child: const Text('Approve'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
