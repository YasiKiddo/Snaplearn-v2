import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/providers/app_provider.dart';
import '../../core/models/course.dart';
import '../../core/services/data_service.dart';
import '../../core/services/local_storage_service.dart';

class CreateCourseScreen extends StatefulWidget {
  final Course? course; // If provided, we are in edit mode

  const CreateCourseScreen({super.key, this.course});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _requirementController = TextEditingController();

  String _category = "Programming";
  bool _isFree = true;
  bool _isLoading = false;
  bool _isPublished = true;

  // Thumbnail file picker state
  String? _thumbnailPath;
  String? _thumbnailFileName;
  PlatformFile? _selectedThumbnailFile;

  List<String> _objectives = [];
  List<String> _requirements = [];

  final List<String> _categories = [
    "Programming",
    "Business",
    "Design",
    "Marketing",
    "English",
    "Finance",
    "Music",
    "Personal Development",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _titleController.text = widget.course!.title;
      _descriptionController.text = widget.course!.description;
      _priceController.text = widget.course!.price.toString();
      _category = widget.course!.category;
      _isFree = widget.course!.isFree;
      _isPublished = widget.course!.status == 'published';
      _objectives = List.from(widget.course!.learningObjectives);
      _requirements = List.from(widget.course!.requirements);
      // Load existing thumbnail
      _thumbnailPath = widget.course!.thumbnailPath;
      if (_thumbnailPath != null && _thumbnailPath!.isNotEmpty) {
        _thumbnailFileName = _thumbnailPath!.split(Platform.pathSeparator).last;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _objectiveController.dispose();
    _requirementController.dispose();
    super.dispose();
  }

  void _addObjective() {
    final text = _objectiveController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _objectives.add(text);
        _objectiveController.clear();
      });
    }
  }

  void _addRequirement() {
    final text = _requirementController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _requirements.add(text);
        _requirementController.clear();
      });
    }
  }

  Future<void> _pickThumbnail() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedThumbnailFile = result.files.single;
        _thumbnailPath = result.files.single.path;
        _thumbnailFileName = result.files.single.name;
      });
    }
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final instructor = appProvider.userProfile!;

      String finalThumbnailUrl = widget.course?.thumbnailUrl ?? '';
      String? finalThumbnailPath = widget.course?.thumbnailPath;
      if (_selectedThumbnailFile != null) {
        finalThumbnailUrl = await LocalStorageService.uploadPhoto(
          _selectedThumbnailFile!,
        );
        finalThumbnailPath = null;
      }

      final courseData = Course(
        id: widget.course?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        instructorId: instructor.id,
        instructorName: instructor.displayName,
        thumbnailUrl: finalThumbnailUrl,
        thumbnailPath: finalThumbnailPath,
        category: _category,
        price: _isFree ? 0.0 : double.tryParse(_priceController.text) ?? 0.0,
        isFree: _isFree,
        status: _isPublished ? 'published' : 'draft',
        learningObjectives: _objectives,
        requirements: _requirements,
      );

      if (widget.course == null) {
        await DataService().addCourse(courseData);
      } else {
        await DataService().updateCourse(courseData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.course == null ? 'Course created!' : 'Course updated!',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving course: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.course == null ? "Create Course" : "Edit Course",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryPink,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveCourse,
              child: const Text(
                "Save",
                style: TextStyle(
                  color: AppColors.primaryPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Basic Information"),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _titleController,
                label: "Course Title",
                hint: "Enter a catchy title...",
                icon: LucideIcons.heading,
                validator: (value) => value!.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: "Description",
                hint: "What is this course about?",
                icon: LucideIcons.fileText,
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(),
              const SizedBox(height: 24),
              _buildSectionTitle("Pricing & Status"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildPriceField()),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Free Course",
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                      Switch(
                        value: _isFree,
                        onChanged: (val) => setState(() => _isFree = val),
                        activeThumbColor: AppColors.primaryPink,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    "Publish Immediately",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isPublished,
                    onChanged: (val) => setState(() => _isPublished = val),
                    activeThumbColor: AppColors.primaryPink,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Curriculum & Media"),
              const SizedBox(height: 16),
              // Thumbnail file picker (replaces URL text field)
              _buildThumbnailPicker(),
              const SizedBox(height: 24),
              _buildListInputSection(
                controller: _objectiveController,
                label: "Learning Objectives",
                hint: "What will students learn?",
                icon: LucideIcons.checkCircle,
                items: _objectives,
                onAdd: _addObjective,
                onRemove: (idx) => setState(() => _objectives.removeAt(idx)),
              ),
              const SizedBox(height: 24),
              _buildListInputSection(
                controller: _requirementController,
                label: "Requirements",
                hint: "e.g. Basic JavaScript knowledge...",
                icon: LucideIcons.alertCircle,
                items: _requirements,
                onAdd: _addRequirement,
                onRemove: (idx) => setState(() => _requirements.removeAt(idx)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the thumbnail file picker widget (replaces the old URL text field)
  Widget _buildThumbnailPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Course Thumbnail",
          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickThumbnail,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _thumbnailPath != null
                    ? AppColors.primaryPink
                    : Colors.white10,
              ),
              image:
                  (_thumbnailPath != null &&
                      _thumbnailPath!.isNotEmpty &&
                      File(_thumbnailPath!).existsSync())
                  ? DecorationImage(
                      image: FileImage(File(_thumbnailPath!)),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.4),
                        BlendMode.darken,
                      ),
                    )
                  : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _thumbnailPath != null
                        ? LucideIcons.checkCircle2
                        : LucideIcons.image,
                    size: 40,
                    color: _thumbnailPath != null
                        ? Colors.green
                        : AppColors.textGrey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _thumbnailFileName ?? 'Tap to select thumbnail image',
                    style: TextStyle(
                      color: _thumbnailPath != null
                          ? Colors.white
                          : AppColors.textGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
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
            keyboardType: keyboardType,
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

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Category",
          style: TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _category,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: Colors.white),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return _buildTextField(
      controller: _priceController,
      label: "Price (USD)",
      hint: "0.00",
      icon: LucideIcons.dollarSign,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (!_isFree && (value == null || value.isEmpty)) return "Enter price";
        return null;
      },
    );
  }

  Widget _buildListInputSection({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Colors.white24,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(
                LucideIcons.plusCircle,
                color: AppColors.primaryPink,
              ),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.check,
                    color: AppColors.primaryPink,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[index],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onRemove(index),
                    icon: const Icon(
                      LucideIcons.trash2,
                      color: Colors.redAccent,
                      size: 16,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
