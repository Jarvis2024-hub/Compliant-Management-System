import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'role_selection_screen.dart';
import 'user/user_dashboard_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'engineer_dashboard.dart';

class DashboardRouter extends StatefulWidget {
  const DashboardRouter({Key? key}) : super(key: key);

  @override
  State<DashboardRouter> createState() => _DashboardRouterState();
}

class _DashboardRouterState extends State<DashboardRouter> {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();

    if (!isLoggedIn) {
      // Navigate to the Role Selection Screen first
      _navigate(const RoleSelectionScreen());
      return;
    }

    final role = await _storage.getRole();

    if (role == 'admin') {
      _navigate(const AdminDashboardScreen());
    } else if (role == 'engineer') {
      _navigate(const EngineerDashboardScreen());
    } else if (role == 'user') {
      _navigate(const UserDashboardScreen());
    } else {
      _navigate(const RoleSelectionScreen());
    }
  }

  void _navigate(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
