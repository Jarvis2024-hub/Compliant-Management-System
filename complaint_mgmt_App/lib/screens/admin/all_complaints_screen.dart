import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/complaint_card.dart';
import '../../widgets/loading_indicator.dart';
import 'complaint_management_screen.dart';

class AllComplaintsScreen extends StatefulWidget {
  final String? initialStatus;

  const AllComplaintsScreen({Key? key, this.initialStatus}) : super(key: key);

  @override
  State<AllComplaintsScreen> createState() => _AllComplaintsScreenState();
}

class _AllComplaintsScreenState extends State<AllComplaintsScreen> {
  final ComplaintService _complaintService = ComplaintService();
  
  List<ComplaintModel> _complaints = [];
  List<ComplaintModel> _filteredComplaints = [];
  bool _isLoading = false;
  
  String? _selectedStatus;
  String? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _complaintService.getAllComplaints(
        status: _selectedStatus,
        priority: _selectedPriority,
      );

      if (response.success && response.data != null) {
        final List<dynamic> complaintsJson = response.data['complaints'];
        setState(() {
          _complaints = complaintsJson
              .map((json) => ComplaintModel.fromJson(json))
              .toList();
          _filteredComplaints = _complaints;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        _showError(response.message);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      _showError('Failed to load complaints');
    }
  }

  void _applyFilters() {
    _loadComplaints();
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedPriority = null;
    });
    _loadComplaints();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Complaints'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedStatus == null,
                      onSelected: (selected) {
                        setDialogState(() {
                          _selectedStatus = null;
                        });
                      },
                    ),
                    ...AppConstants.statuses.map((status) {
                      return FilterChip(
                        label: Text(status),
                        selected: _selectedStatus == status,
                        onSelected: (selected) {
                          setDialogState(() {
                            _selectedStatus = selected ? status : null;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Priority',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedPriority == null,
                      onSelected: (selected) {
                        setDialogState(() {
                          _selectedPriority = null;
                        });
                      },
                    ),
                    ...AppConstants.priorities.map((priority) {
                      return FilterChip(
                        label: Text(priority),
                        selected: _selectedPriority == priority,
                        onSelected: (selected) {
                          setDialogState(() {
                            _selectedPriority = selected ? priority : null;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearFilters();
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applyFilters();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Complaints'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComplaints,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedStatus != null || _selectedPriority != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue[50],
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filters: ${_selectedStatus ?? 'All Status'}, ${_selectedPriority ?? 'All Priority'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Loading complaints...')
                : _filteredComplaints.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No complaints found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadComplaints,
                        child: ListView.builder(
                          itemCount: _filteredComplaints.length,
                          itemBuilder: (context, index) {
                            final complaint = _filteredComplaints[index];
                            return ComplaintCard(
                              complaint: complaint,
                              showUserInfo: true,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ComplaintManagementScreen(
                                      complaint: complaint,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadComplaints();
                                }
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}