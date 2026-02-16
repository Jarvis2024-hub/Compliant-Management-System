import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../models/category_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/premium_logo.dart';
import '../dashboard_router.dart';

class StaffAuthScreen extends StatefulWidget {
  final String? initialRole;
  const StaffAuthScreen({Key? key, this.initialRole}) : super(key: key);

  @override
  State<StaffAuthScreen> createState() => _StaffAuthScreenState();
}

class _StaffAuthScreenState extends State<StaffAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  late String _staffRole;

  List<String> _specializationNames = [
    'AC Repair', 'Carpentry', 'Civil', 'Cleaning',
    'Electrical', 'Facility', 'Hardware', 'Network',
    'Painting', 'Plumbing', 'Software', 'Other'
  ];
  String? _selectedSpecialization;
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _staffRole = widget.initialRole ?? 'engineer';
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Silent load - don't show loading indicator on UI to prevent blocking
    try {
      final response = await _apiService.get(ApiConfig.categoriesList);
      if (response.success && response.data != null) {
        final List<dynamic> categoriesJson = response.data['categories'];
        final List<String> fetchedNames = categoriesJson
            .map((json) => CategoryModel.fromJson(json).categoryName)
            .toList();

        if (fetchedNames.isNotEmpty && mounted) {
          setState(() {
            _specializationNames = fetchedNames;
          });
        }
      }
    } catch (e) {
      // Silently fail - use default hardcoded list if API fails
      debugPrint('Category fetch failed: $e');
    }
  }

  Future<void> _handleStaffAuth() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLogin && _staffRole == 'engineer' && _selectedSpecialization == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your specialization'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final response = _isLogin 
      ? await _authService.login(_emailController.text.trim(), _passwordController.text)
      : await _authService.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _staffRole,
          specialization: _staffRole == 'engineer' ? _selectedSpecialization : null,
        );

    setState(() => _isLoading = false);

    if (response.success) {
      if (!mounted) return;
      if (!_isLogin) {
        _showSuccessDialog('Your account request has been sent for approval. You will be able to login once an administrator approves your request.');
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardRouter()),
        );
      }
    } else {
      _showErrorDialog(response.message);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    final response = await _authService.signInWithGoogle(_staffRole);
    setState(() => _isGoogleLoading = false);

    if (response.success) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardRouter()),
      );
    } else {
      _showErrorDialog(response.message);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access Restricted'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Request Sent'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isLogin = true);
            }, 
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: PremiumLogo(size: 70)),
              const SizedBox(height: 24),
              Text(
                _isLogin ? 'Staff Login' : 'Request Staff Access',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkNavy),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin ? 'Accessing as ${_staffRole.toUpperCase()}' : 'Registering as ${_staffRole.toUpperCase()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                        validator: (v) => (v == null || v.isEmpty) ? 'Name required' : null,
                      ),
                      const SizedBox(height: 16),

                      // 🚀 FIXED SPECIALIZATION DROPDOWN
                      if (_staffRole == 'engineer') ...[
                        DropdownButtonFormField<String>(
                          value: _selectedSpecialization,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Engineer Specialization',
                            prefixIcon: Icon(Icons.psychology_outlined),
                          ),
                          hint: const Text('Select specialization'),
                          items: _specializationNames.map((name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedSpecialization = value;
                            });
                          },
                          validator: (v) => v == null ? 'Specialization required' : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Staff Email', prefixIcon: Icon(Icons.email_outlined)),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline_rounded)),
                      validator: (v) => (v == null || v.isEmpty) ? 'Password required' : null,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleStaffAuth,
                child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_isLogin ? 'Login to Dashboard' : 'Submit Access Request'),
              ),
              
              if (_isLogin) ...[
                const SizedBox(height: 24),
                const Center(child: Text('OR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 32, color: AppColors.primary),
                  label: const Text('Continue with Google', style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => setState(() {
                  _isLogin = !_isLogin;
                  _selectedSpecialization = null; // Clear on toggle
                }),
                child: Text(
                  _isLogin ? "New staff? Request access" : "Back to Login",
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
