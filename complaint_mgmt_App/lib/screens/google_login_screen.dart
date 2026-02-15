import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import 'user/user_dashboard_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class GoogleLoginScreen extends StatefulWidget {
  final String role;

  const GoogleLoginScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.signInWithGoogle(widget.role);

      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate based on role
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => widget.role == 'admin'
                ? const AdminDashboardScreen()
                : const UserDashboardScreen(),
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login as ${widget.role == 'admin' ? 'Admin' : 'User'}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.role == 'admin'
                      ? Icons.admin_panel_settings
                      : Icons.person,
                  size: 100,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome ${widget.role == 'admin' ? 'Admin' : 'User'}!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.role == 'admin'
                      ? 'Sign in to manage complaints'
                      : 'Sign in to register your complaints',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                CustomButton(
                  text: 'Sign in with Google',
                  icon: Icons.login,
                  onPressed: _handleGoogleSignIn,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                const Text(
                  'By signing in, you agree to our Terms & Conditions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}