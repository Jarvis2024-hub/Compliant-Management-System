import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/custom_button.dart';
import 'add_response_screen.dart';

class ComplaintManagementScreen extends StatefulWidget {
  final ComplaintModel complaint;

  const ComplaintManagementScreen({Key? key, required this.complaint})
      : super(key: key);

  @override
  State<ComplaintManagementScreen> createState() =>
      _ComplaintManagementScreenState();
}

class _ComplaintManagementScreenState extends State<ComplaintManagementScreen> {
  final ComplaintService _complaintService = ComplaintService();
  
  late ComplaintModel _complaint;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
  }

  Future<void> _updateStatus(String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Text('Change status to "$newStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final response = await _complaintService.updateComplaintStatus(
        complaintId: _complaint.id,
        status: newStatus,
      );

      setState(() {
        _isUpdating = false;
      });

      if (!mounted) return;

      if (response.success) {
        setState(() {
          _complaint = ComplaintModel(
            id: _complaint.id,
            description: _complaint.description,
            priority: _complaint.priority,
            status: newStatus,
            categoryName: _complaint.categoryName,
            createdAt: _complaint.createdAt,
            userName: _complaint.userName,
            userEmail: _complaint.userEmail,
            adminResponse: _complaint.adminResponse,
            responseDate: _complaint.responseDate,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        _showError(response.message);
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      if (!mounted) return;
      _showError('Failed to update status');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Color _getPriorityColor() {
    switch (_complaint.priority) {
      case 'High':
        return AppColors.priorityHigh;
      case 'Medium':
        return AppColors.priorityMedium;
      case 'Low':
        return AppColors.priorityLow;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Complaint'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Current Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        StatusBadge(status: _complaint.status),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('ID', '#${_complaint.id}', Icons.tag),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Category',
                      _complaint.categoryName,
                      Icons.category,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Priority',
                      _complaint.priority,
                      Icons.flag,
                      color: _getPriorityColor(),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Submitted',
                      _formatDate(_complaint.createdAt),
                      Icons.access_time,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'User Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Name',
                      _complaint.userName ?? 'N/A',
                      Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Email',
                      _complaint.userEmail ?? 'N/A',
                      Icons.email,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _complaint.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            if (_complaint.adminResponse != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Admin Response',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.admin_panel_settings,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Response on ${_formatDate(_complaint.responseDate ?? '')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Text(
                        _complaint.adminResponse!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Update Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.statuses.map((status) {
                final isCurrentStatus = status == _complaint.status;
                return ElevatedButton(
                  onPressed: isCurrentStatus || _isUpdating
                      ? null
                      : () => _updateStatus(status),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrentStatus
                        ? AppColors.primary
                        : Colors.grey[200],
                    foregroundColor:
                        isCurrentStatus ? Colors.white : AppColors.textPrimary,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(status),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: _complaint.adminResponse == null
                  ? 'Add Response'
                  : 'Update Response',
              icon: Icons.reply,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddResponseScreen(
                      complaint: _complaint,
                    ),
                  ),
                );
                if (result == true) {
                  if (!mounted) return;
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    try {
      final DateTime dt = DateTime.parse(date);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
  }
}