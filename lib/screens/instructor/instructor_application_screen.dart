import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/data_service.dart';

class InstructorApplicationScreen extends StatefulWidget {
  const InstructorApplicationScreen({super.key});

  @override
  State<InstructorApplicationScreen> createState() =>
      _InstructorApplicationScreenState();
}

class _InstructorApplicationScreenState
    extends State<InstructorApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _experienceController = TextEditingController();
  final _expertiseController = TextEditingController();
  final _linksController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _experienceController.dispose();
    _expertiseController.dispose();
    _linksController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final uid = appProvider.currentUser!.uid;

      final applicationData = {
        'instructorReason': _reasonController.text.trim(),
        'instructorExperience': _experienceController.text.trim(),
        'instructorExpertise': _expertiseController.text.trim(),
        'instructorLinks': _linksController.text.trim(),
      };

      await DataService().submitInstructorApplication(uid, applicationData);
      await appProvider.refreshProfile();

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting application: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Application Submitted",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Your application to become an instructor has been received. Our team will review it and get back to you shortly.",
          style: TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to profile
            },
            child: const Text(
              "Great!",
              style: TextStyle(color: AppColors.primaryPink),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "Become an Instructor",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Join our community of instructors and share your knowledge with thousands of students.",
                style: TextStyle(color: AppColors.textGrey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _expertiseController,
                label: "Area of Expertise",
                hint:
                    "e.g. Flutter Development, UI/UX Design, English Language...",
                icon: LucideIcons.award,
                validator: (value) =>
                    value!.isEmpty ? "Please specify your expertise" : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _experienceController,
                label: "Years of Experience",
                hint: "How long have you been in this field?",
                icon: LucideIcons.clock,
                validator: (value) =>
                    value!.isEmpty ? "Please specify your experience" : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _reasonController,
                label: "Why do you want to teach on SnapLearn?",
                hint: "Tell us about your teaching philosophy...",
                icon: LucideIcons.messageSquare,
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? "Please tell us why" : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _linksController,
                label: "Professional Links",
                hint: "LinkedIn, Portfolio, GitHub...",
                icon: LucideIcons.link,
                maxLines: 2,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Submit Application",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
