import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/complaint_card.dart';
import '../../widgets/loading_indicator.dart';
import 'complaint_management_screen.dart';

class AllComplaintsScreen extends StatefulWidget {
  final String? initialStatus;

  const AllComplaintsScreen({Key? key, this.initialStatus}) : super(key: key);

  @override
  State<AllComplaintsScreen> createState() => _AllComplaintsScreenState();
}

class _AllComplaintsScreenState extends State<AllComplaintsScreen> with SingleTickerProviderStateMixin {
  final ComplaintService _complaintService = ComplaintService();
  late TabController _tabController;

  List<ComplaintModel> _allComplaints = [];
  bool _isLoading = false;
  
  final List<String> _tabs = ['All', 'Pending', 'Assigned', 'In Progress', 'Resolved'];

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.initialStatus != null) {
      initialIndex = _tabs.indexOf(widget.initialStatus!);
      if (initialIndex == -1) initialIndex = 0;
    }

    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Refresh list based on new tab
      }
    });

    _loadComplaints();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);
    try {
      final response = await _complaintService.getAllComplaints();
      if (response.success && response.data != null) {
        final List<dynamic> complaintsJson = response.data is List
            ? response.data
            : (response.data['complaints'] ?? []);

        setState(() {
          _allComplaints = complaintsJson
              .map((json) => ComplaintModel.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (!mounted) return;
        _showError(response.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showError('Failed to load complaints');
    }
  }

  List<ComplaintModel> _getFilteredComplaints() {
    final String currentStatus = _tabs[_tabController.index];
    if (currentStatus == 'All') return _allComplaints;
    return _allComplaints.where((c) => c.status == currentStatus).toList();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredComplaints();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints Manager'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _tabs.map((status) => Tab(text: status)).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadComplaints,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Syncing system data...')
          : filteredList.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadComplaints,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final complaint = filteredList[index];
                      return ComplaintCard(
                        complaint: complaint,
                        showUserInfo: true,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComplaintManagementScreen(complaint: complaint),
                            ),
                          );
                          if (result == true) _loadComplaints();
                        },
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No ${_tabs[_tabController.index]} tickets',
            style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
