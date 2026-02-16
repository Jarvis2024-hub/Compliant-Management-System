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
  List<dynamic> _availableEngineers = [];
  bool _isLoadingEngineers = false;

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
    if (_complaint.engineerName == null) {
      _loadEngineers();
    }
  }

  Future<void> _loadEngineers() async {
    setState(() => _isLoadingEngineers = true);
    try {
      final response = await _complaintService.getEngineersByCategory(_complaint.categoryName);
      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            // Robust check for both raw List or nested Map formats
            if (response.data is List) {
              _availableEngineers = response.data;
            } else if (response.data is Map && response.data['engineers'] != null) {
              _availableEngineers = response.data['engineers'];
            }
          }
          _isLoadingEngineers = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingEngineers = false);
    }
  }

  Future<void> _assignEngineer(int engineerId, String engineerName) async {
    setState(() => _isUpdating = true);
    final response = await _complaintService.assignEngineer(
      complaintId: _complaint.id,
      engineerId: engineerId,
    );

    if (mounted) {
      setState(() => _isUpdating = false);
      if (response.success) {
        setState(() {
          _shouldRefresh = true; // Flag to reload parent list on exit
          _complaint = ComplaintModel(
            id: _complaint.id,
            description: _complaint.description,
            priority: _complaint.priority,
            status: 'In Progress', // Match backend and schema
            categoryName: _complaint.categoryName,
            createdAt: _complaint.createdAt,
            userName: _complaint.userName,
            userEmail: _complaint.userEmail,
            adminResponse: _complaint.adminResponse,
            responseDate: _complaint.responseDate,
            engineerName: engineerName,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Engineer assigned successfully'), backgroundColor: AppColors.success),
        );
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Text('Change status to "$newStatus"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Update')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isUpdating = true);
    final response = await _complaintService.updateComplaintStatus(
      complaintId: _complaint.id,
      status: newStatus,
    );

    if (mounted) {
      setState(() => _isUpdating = false);
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
            engineerName: _complaint.engineerName,
            engineerResponse: _complaint.engineerResponse,
          );
        });
      }
    }
  }

  bool _shouldRefresh = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _shouldRefresh);
        return false;
      },
      child: Scaffold(
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
              if (_complaint.engineerName == null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: AppColors.error),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Auto-assignment failed. Please assign an engineer manually.',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ticket Info', style: TextStyle(fontWeight: FontWeight.bold)),
                          StatusBadge(status: _complaint.status),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('ID', '#${_complaint.id}', Icons.tag),
                      const SizedBox(height: 12),
                      _buildInfoRow('Category', _complaint.categoryName, Icons.category),
                      const SizedBox(height: 12),
                      _buildInfoRow('Priority', _complaint.priority, Icons.flag),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text('Engineer Assignment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _complaint.engineerName != null
                      ? _buildInfoRow('Assigned To', _complaint.engineerName!, Icons.engineering, color: AppColors.success)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Select an engineer to assign:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 12),
                            if (_isLoadingEngineers)
                              const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                            else if (_availableEngineers.isEmpty)
                              const Text('No engineers found for this category', style: TextStyle(color: AppColors.error, fontSize: 13))
                            else
                              DropdownButtonFormField<int>(
                                isExpanded: true,
                                decoration: const InputDecoration(hintText: 'Choose Engineer', border: OutlineInputBorder()),
                                items: _availableEngineers.map((eng) {
                                  return DropdownMenuItem<int>(
                                    value: int.parse(eng['id'].toString()),
                                    child: Text(eng['name']),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    final eng = _availableEngineers.firstWhere((e) => int.parse(e['id'].toString()) == val);
                                    _assignEngineer(val, eng['name']);
                                  }
                                },
                              ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),
              const Text('User Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('User', _complaint.userName ?? 'N/A', Icons.person),
                      const SizedBox(height: 12),
                      _buildInfoRow('Email', _complaint.userEmail ?? 'N/A', Icons.email),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_complaint.description, style: const TextStyle(fontSize: 14, height: 1.5)),
                ),
              ),

              const SizedBox(height: 24),
              const Text('Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: AppConstants.statuses.map((status) {
                  final isCurrent = status == _complaint.status;
                  return ChoiceChip(
                    label: Text(status),
                    selected: isCurrent,
                    onSelected: isCurrent || _isUpdating ? null : (selected) => _updateStatus(status),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Add System Response',
                icon: Icons.reply,
                onPressed: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddResponseScreen(complaint: _complaint)));
                  if (result == true) {
                     setState(() => _shouldRefresh = true); // Mark as needed refresh
                     Navigator.of(context).pop(true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color ?? AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    try {
      final DateTime dt = DateTime.parse(date);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return date;
    }
  }
}
