import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/app_feature.dart';
import '../../core/services/data_service.dart';

class AddFeatureScreen extends StatefulWidget {
  final AppFeature? feature;

  const AddFeatureScreen({super.key, this.feature});

  @override
  State<AddFeatureScreen> createState() => _AddFeatureScreenState();
}

class _AddFeatureScreenState extends State<AddFeatureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final DataService _dataService = DataService();

  bool _isLoading = false;
  String _selectedColorHex = 'FF1E1B4B'; // default codingPurple
  String _selectedIcon = 'star';

  final Map<String, String> _colorOptions = {
    'Purple (Coding)': 'FF1E1B4B',
    'Gold (Business)': 'FF422006',
    'Teal (English)': 'FF083344',
    'Pink (Primary)': 'FFFF4BFF',
    'Red (Alert)': 'FFFD1D1D',
  };

  final Map<String, IconData> _iconOptions = {
    'star': LucideIcons.star,
    'code': LucideIcons.code,
    'bookOpen': LucideIcons.bookOpen,
    'video': LucideIcons.video,
    'briefcase': LucideIcons.briefcase,
    'penTool': LucideIcons.penTool,
    'megaphone': LucideIcons.megaphone,
    'rocket': LucideIcons.rocket,
    'zap': LucideIcons.zap,
  };

  @override
  void initState() {
    super.initState();
    if (widget.feature != null) {
      _titleController.text = widget.feature!.title;
      _subtitleController.text = widget.feature!.subtitle;
      _selectedColorHex = widget.feature!.colorHex;
      _selectedIcon = widget.feature!.iconName;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newFeature = AppFeature(
        id: widget.feature?.id ?? '',
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim(),
        colorHex: _selectedColorHex,
        iconName: _selectedIcon,
        createdAt: widget.feature?.createdAt ?? DateTime.now(),
      );

      if (widget.feature == null) {
        await _dataService.addAppFeature(newFeature);
      } else {
        await _dataService.updateAppFeature(newFeature);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feature saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.feature == null ? 'Add Feature Banner' : 'Edit Feature Banner',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                icon: LucideIcons.type,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _subtitleController,
                label: 'Subtitle',
                icon: LucideIcons.alignLeft,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Background Color',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildColorDropdown(),
              const SizedBox(height: 24),
              const Text(
                'Icon',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildIconDropdown(),
              const SizedBox(height: 32),
              _buildPreview(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.feature == null
                              ? 'Create Banner'
                              : 'Update Banner',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey),
        prefixIcon: Icon(icon, color: AppColors.textGrey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryPink),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      validator: validator,
    );
  }

  Widget _buildColorDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedColorHex,
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryPink),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      items: _colorOptions.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.value,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(int.parse(entry.value, radix: 16)),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(entry.key),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedColorHex = value;
          });
        }
      },
    );
  }

  Widget _buildIconDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedIcon,
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryPink),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      items: _iconOptions.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Row(
            children: [
              Icon(entry.value, color: Colors.white70),
              const SizedBox(width: 12),
              Text(entry.key),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedIcon = value;
          });
        }
      },
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          height: 160,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(int.parse(_selectedColorHex, radix: 16)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "FEATURED",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _titleController.text.isEmpty
                          ? "Title"
                          : _titleController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitleController.text.isEmpty
                          ? "Subtitle"
                          : _subtitleController.text,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                _iconOptions[_selectedIcon],
                size: 60,
                color: Colors.white24,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
