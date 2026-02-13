import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddResponseScreen extends StatefulWidget {
  final ComplaintModel complaint;

  const AddResponseScreen({Key? key, required this.complaint})
      : super(key: key);

  @override
  State<AddResponseScreen> createState() => _AddResponseScreenState();
}

class _AddResponseScreenState extends State<AddResponseScreen> {
  final _formKey = GlobalKey<FormState>();
  final ComplaintService _complaintService = ComplaintService();
  final TextEditingController _responseController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.complaint.adminResponse != null) {
      _responseController.text = widget.complaint.adminResponse!;
    }
  }

  Future<void> _submitResponse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _complaintService.addAdminResponse(
        complaintId: widget.complaint.id,
        response: _responseController.text.trim(),
      );

      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.complaint.adminResponse == null
                  ? 'Response added successfully'
                  : 'Response updated successfully',
            ),
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
      _showError('Failed to submit response');
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
        title: Text(
          widget.complaint.adminResponse == null
              ? 'Add Response'
              : 'Update Response',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                      const Text(
                        'Complaint Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Divider(height: 16),
                      _buildInfoRow('Category', widget.complaint.categoryName),
                      const SizedBox(height: 8),
                      _buildInfoRow('Priority', widget.complaint.priority),
                      const SizedBox(height: 8),
                      _buildInfoRow('Status', widget.complaint.status),
                      const Divider(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.complaint.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Your Response',
                hint: 'Enter your response to the user...',
                controller: _responseController,
                validator: Validators.validateResponse,
                maxLines: 8,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 8),
              Text(
                'This response will be visible to the user who submitted the complaint.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: widget.complaint.adminResponse == null
                    ? 'Submit Response'
                    : 'Update Response',
                icon: Icons.send,
                onPressed: _submitResponse,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }
}