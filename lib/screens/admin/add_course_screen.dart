import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/models/course.dart';
import '../../core/services/data_service.dart';
import '../../core/services/local_storage_service.dart';

class AddCourseScreen extends StatefulWidget {
  final Course? course;
  const AddCourseScreen({super.key, this.course});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _instructorNameController;
  String? _thumbnailPath; // Persistent local path
  String? _thumbnailFileName;
  PlatformFile? _selectedThumbnailFile; // Newly picked file (not yet persisted)
  bool _isLoading = false;

  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title);
    _descriptionController = TextEditingController(
      text: widget.course?.description,
    );
    _categoryController = TextEditingController(text: widget.course?.category);
    _instructorNameController = TextEditingController(
      text: widget.course?.instructorName,
    );
    // Load existing thumbnail path from the course
    _thumbnailPath =
        widget.course?.thumbnailPath ?? widget.course?.thumbnailUrl;
    if (_thumbnailPath != null && _thumbnailPath!.isNotEmpty) {
      _thumbnailFileName = _thumbnailPath!.split(Platform.pathSeparator).last;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _instructorNameController.dispose();
    super.dispose();
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
      String finalThumbnailUrl = widget.course?.thumbnailUrl ?? '';
      String? finalThumbnailPath = widget.course?.thumbnailPath;

      if (_selectedThumbnailFile != null) {
        finalThumbnailUrl = await LocalStorageService.uploadPhoto(
          _selectedThumbnailFile!,
        );
        finalThumbnailPath = null;
      }

      final updatedCourse = Course(
        id: widget.course?.id ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        instructorId: widget.course?.instructorId ?? 'admin_1',
        instructorName: _instructorNameController.text,
        thumbnailUrl: finalThumbnailUrl,
        thumbnailPath: finalThumbnailPath,
        category: _categoryController.text,
        lessonIds: widget.course?.lessonIds ?? [],
        enrolledCount: widget.course?.enrolledCount ?? 0,
        rating: widget.course?.rating ?? 0.0,
      );

      if (widget.course == null) {
        await _dataService.addCourse(updatedCourse);
      } else {
        await _dataService.updateCourse(updatedCourse);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        title: Text(
          widget.course == null ? 'Create New Course' : 'Edit Course',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Course Title',
                hint: 'e.g. Flutter Masterclass',
                icon: LucideIcons.type,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe what students will learn...',
                icon: LucideIcons.fileText,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _categoryController,
                label: 'Category',
                hint: 'e.g. CODING, DESIGN',
                icon: LucideIcons.tag,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _instructorNameController,
                label: 'Instructor Name',
                hint: 'Your Name or Institution',
                icon: LucideIcons.user,
              ),
              const SizedBox(height: 30),
              const Text(
                'Course Thumbnail',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
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
                      style: BorderStyle.solid,
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
                          _thumbnailFileName ??
                              'Tap to select thumbnail from laptop',
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
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.course == null
                            ? 'Create Course'
                            : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textGrey),
              prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) => value == null || value.isEmpty
                ? 'This field is required'
                : null,
          ),
        ),
      ],
    );
  }
}
