import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../utils/app_colors.dart';
import '../../config/api_config.dart';

class AssignedComplaintsScreen extends StatefulWidget {
  const AssignedComplaintsScreen({Key? key}) : super(key: key);

  @override
  State<AssignedComplaintsScreen> createState() => _AssignedComplaintsScreenState();
}

class _AssignedComplaintsScreenState extends State<AssignedComplaintsScreen> {
  final ComplaintService _complaintService = ComplaintService();
  List<dynamic> _complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);

    final response = await _complaintService.getAssignedComplaints();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success) {
          _complaints = response.data;
        } else {
          _complaints = []; 
        }
      });
    }
  }

  Future<void> _updateStatus(int complaintId, String newStatus) async {
    final response = await _complaintService.updateComplaintStatus(
      complaintId: complaintId,
      status: newStatus,
    );

    if (mounted) {
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully'), backgroundColor: AppColors.success),
        );
        _loadComplaints();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showStatusDialog(Map<String, dynamic> complaint) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Update Status'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(int.parse(complaint['id'].toString()), 'In Progress');
            },
            child: const Text('In Progress', style: TextStyle(color: AppColors.statusInProgress)),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(int.parse(complaint['id'].toString()), 'Resolved');
            },
            child: const Text('Resolved', style: TextStyle(color: AppColors.statusResolved)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Complaints'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
              ? const Center(child: Text('No assigned complaints'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = _complaints[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '#${complaint['id']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    complaint['status'] ?? 'Unknown',
                                    style: const TextStyle(
                                      color: Colors.blue, 
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              complaint['category_name'] ?? 'Category',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(complaint['description'] ?? ''),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _showStatusDialog(complaint),
                                  child: const Text('Update Status'),
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
