import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/complaint_service.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';
import '../role_selection_screen.dart';
import 'all_complaints_screen.dart';
import 'admin_pending_users_screen.dart';
import '../../widgets/role_badge.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthService _authService = AuthService();
  final ComplaintService _complaintService = ComplaintService();
  UserModel? _currentUser;
  bool _isLoading = true;
  int _unassignedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final user = await _authService.getCurrentUser();

    // Fetch all complaints to count "Pending Assignment"
    final response = await _complaintService.getAllComplaints(status: 'Pending Assignment');

    setState(() {
      _currentUser = user;
      if (response.success && response.data != null) {
        // Corrected: Safely access the nested 'complaints' list from the backend response object
        final dynamic data = response.data;
        if (data is Map && data.containsKey('complaints')) {
          _unassignedCount = (data['complaints'] as List).length;
        } else if (data is List) {
          _unassignedCount = data.length;
        }
      } else {
        _unassignedCount = 0;
      }
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Administrative Console', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildActionCard(
                    title: 'All Complaints',
                    description: 'Full system oversight and management',
                    icon: Icons.dashboard_customize_rounded,
                    color: AppColors.primary,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllComplaintsScreen())).then((_) => _loadDashboardData()),
                  ),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    title: 'Unassigned Complaints',
                    description: 'Manual intervention required',
                    icon: Icons.assignment_late_rounded,
                    color: AppColors.error,
                    badgeCount: _unassignedCount,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllComplaintsScreen(initialStatus: 'Pending Assignment'))).then((_) => _loadDashboardData()),
                  ),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    title: 'User Approvals',
                    description: 'Verify new staff registration requests',
                    icon: Icons.person_add_rounded,
                    color: AppColors.accent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPendingUsersScreen())).then((_) => _loadDashboardData()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      actions: [
        IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white), onPressed: _loadDashboardData),
        IconButton(icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white), onPressed: _handleLogout),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.darkNavy, AppColors.primary])),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const RoleBadge(role: 'SYSTEM ADMIN'),
                  const SizedBox(height: 12),
                  Text('Hi, ${_currentUser?.name}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  Text('${_currentUser?.email}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildMiniStat('Active', '24', AppColors.primary),
        const SizedBox(width: 12),
        _buildMiniStat('Alerts', '$_unassignedCount', AppColors.error),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required String title, required String description, required IconData icon, required Color color, int? badgeCount, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 28)),
                    if (badgeCount != null && badgeCount > 0)
                      Positioned(right: 0, top: 0, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text(description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))])),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.mutedText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
