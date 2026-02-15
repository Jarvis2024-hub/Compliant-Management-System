import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/premium_logo.dart';
import 'dashboard_router.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String? _selectedRole;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _cardController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));

    _logoController.forward();
    _cardController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _cardController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_selectedRole == null) {
      _showSnackbar('Please select a role');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final response = await _authService.login(_emailController.text.trim(), _passwordController.text);
    setState(() => _isLoading = false);
    if (response.success) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardRouter()));
    } else {
      _showErrorDialog(response.message);
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (_selectedRole == null) {
      _showSnackbar('Please select a role');
      return;
    }
    setState(() => _isGoogleLoading = true);
    final response = await _authService.signInWithGoogle(_selectedRole!);
    setState(() => _isGoogleLoading = false);
    if (response.success) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardRouter()));
    } else {
      _showErrorDialog(response.message);
    }
  }

  void _showSnackbar(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.error));
  void _showErrorDialog(String message) => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Access Restricted'), content: Text(message), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(
        children: [
          // Top 40% Gradient Background
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.darkNavy, AppColors.primary],
              ),
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PremiumLogo(size: 90),
                    const SizedBox(height: 20),
                    const Text('ResolvePro', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
                    const SizedBox(height: 6),
                    Text('Smart Complaint Resolution System', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),

          // Bottom 60% White Card
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.62,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, -10))],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildRoleSelector(),
                      const SizedBox(height: 24),
                      _buildLoginForm(),
                      const SizedBox(height: 32),
                      _buildAuthOptions(),
                      const SizedBox(height: 40),
                      _buildRegisterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SELECT YOUR ROLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedText, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          hint: const Text('Choose role to continue'),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 20)),
          items: const [
            DropdownMenuItem(value: 'user', child: Text('Corporate User')),
            DropdownMenuItem(value: 'engineer', child: Text('Service Engineer')),
            DropdownMenuItem(value: 'admin', child: Text('System Administrator')),
          ],
          onChanged: (v) => setState(() => _selectedRole = v!),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Work Email', prefixIcon: Icon(Icons.mail_outline_rounded, size: 20)),
            validator: (v) => (v == null || !v.contains('@')) ? 'Valid work email required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Security Password', prefixIcon: Icon(Icons.lock_open_rounded, size: 20)),
            validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthOptions() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Continue with Email'),
        ),
        const SizedBox(height: 16),
        const Text('OR SIGN IN USING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.mutedText, letterSpacing: 1.0)),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
          icon: const Icon(Icons.g_mobiledata_rounded, size: 32, color: AppColors.primary),
          label: _isGoogleLoading ? const CircularProgressIndicator() : const Text('Continue with Google', style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade200),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
          child: const Text('Request Access', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
