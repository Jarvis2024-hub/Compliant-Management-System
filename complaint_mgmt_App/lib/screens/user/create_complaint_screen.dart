import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../models/category_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

class CreateComplaintScreen extends StatefulWidget {
  const CreateComplaintScreen({Key? key}) : super(key: key);

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final ComplaintService _complaintService = ComplaintService();
  final TextEditingController _descriptionController = TextEditingController();

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  String _selectedPriority = 'Low';
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _complaintService.getCategories();

      if (response.success && response.data != null) {
        final List<dynamic> categoriesJson = response.data['categories'];
        setState(() {
          _categories = categoriesJson
              .map((json) => CategoryModel.fromJson(json))
              .toList();
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
      _showError('Failed to load categories');
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _complaintService.createComplaint(
        categoryId: _selectedCategory!.id,
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint registered successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        _showError(response.message);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (!mounted) return;
      _showError('Failed to submit complaint');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Complaint'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading categories...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<CategoryModel>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        hintText: 'Select category',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.categoryName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Description',
                      hint: 'Describe your complaint in detail',
                      controller: _descriptionController,
                      validator: Validators.validateDescription,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: AppConstants.priorities.map((priority) {
                        return ChoiceChip(
                          label: Text(priority),
                          selected: _selectedPriority == priority,
                          onSelected: (selected) {
                            setState(() {
                              _selectedPriority = priority;
                            });
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _selectedPriority == priority
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Submit Complaint',
                      icon: Icons.send,
                      onPressed: _submitComplaint,
                      isLoading: _isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}