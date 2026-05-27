import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/lesson.dart';
import '../../core/models/course.dart';
import '../../core/services/data_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/providers/app_provider.dart';

class AddVideoScreen extends StatefulWidget {
  final Lesson? lesson;
  const AddVideoScreen({super.key, this.lesson});

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _hashtagController;
  late TextEditingController _videoUrlController;

  List<String> _hashtags = [];
  String? _videoPath;
  String? _videoFileName;
  PlatformFile? _selectedVideoFile;
  String? _selectedCourseId;
  bool _isUploading = false;
  bool _isShortVideo = false;

  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.lesson?.title);
    _descriptionController = TextEditingController(
      text: widget.lesson?.description,
    );
    _categoryController = TextEditingController(text: widget.lesson?.category);
    _hashtagController = TextEditingController();
    _videoUrlController = TextEditingController(text: widget.lesson?.videoUrl);
    _hashtags = List.from(widget.lesson?.hashtags ?? []);
    _videoPath = widget.lesson?.videoPath;
    _selectedCourseId = widget.lesson?.courseId;
    _isShortVideo = widget.lesson?.courseId == null;

    if (_videoPath != null && _videoPath!.isNotEmpty) {
      _videoFileName = _videoPath!.split(Platform.pathSeparator).last;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _hashtagController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.video,
      withData: true,
    );

    if (result != null) {
      final file = result.files.single;
      setState(() {
        _selectedVideoFile = file;
        _videoPath = file.path;
        _videoFileName = file.name;
        _videoUrlController.clear();
      });
    }
  }

  void _addHashtag() {
    final tag = _hashtagController.text.trim().replaceAll('#', '');
    if (tag.isNotEmpty && !_hashtags.contains(tag)) {
      setState(() {
        _hashtags.add(tag);
        _hashtagController.clear();
      });
    }
  }

  Future<void> _saveVideo() async {
    final hasVideoSource =
        _selectedVideoFile != null ||
        (_videoPath != null && _videoPath!.isNotEmpty) ||
        _videoUrlController.text.trim().isNotEmpty;

    if (!_formKey.currentState!.validate() || !hasVideoSource) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select a video'),
        ),
      );
      return;
    }

    if (!_isShortVideo && _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course for tutorial videos'),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final instructor = appProvider.userProfile!;

      String finalVideoUrl = _videoUrlController.text.trim();
      String? finalVideoPath = widget.lesson?.videoPath;

      if (_selectedVideoFile != null) {
        finalVideoUrl = await LocalStorageService.uploadVideo(
          _selectedVideoFile!,
        );
        finalVideoPath = null;
      } else if (finalVideoUrl.isNotEmpty) {
        finalVideoPath = null;
      }

      final lessonData = Lesson(
        id: widget.lesson?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim().toUpperCase(),
        videoUrl: finalVideoUrl,
        videoPath: finalVideoPath,
        courseId: _isShortVideo ? null : _selectedCourseId,
        instructorId: instructor.id,
        hashtags: _hashtags,
        durationSeconds: widget.lesson?.durationSeconds ?? 60,
        status: 'published',
      );

      if (widget.lesson == null) {
        await _dataService.addLesson(lessonData);
      } else {
        await _dataService.updateLesson(lessonData);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.lesson == null ? 'Upload Video' : 'Edit Video',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTypeToggle(),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _titleController,
                label: 'Video Title',
                hint: 'e.g. Introduction to Flutter',
                icon: LucideIcons.type,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _descriptionController,
                label: 'Caption / Description',
                hint: 'What is this video about?',
                icon: LucideIcons.fileText,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _categoryController,
                label: 'Category',
                hint: 'e.g. CODING, DESIGN, BUSINESS',
                icon: LucideIcons.tag,
              ),
              const SizedBox(height: 20),
              if (!_isShortVideo) ...[
                const Text(
                  'Assign to Course',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildCourseDropdown(),
                const SizedBox(height: 20),
              ],
              _buildHashtagInput(),
              const SizedBox(height: 30),
              _buildTextField(
                controller: _videoUrlController,
                label: 'Public Video URL',
                hint: 'https://example.com/video.mp4',
                icon: LucideIcons.link,
              ),
              const SizedBox(height: 10),
              const Text(
                'Use a public MP4 URL, or select a local video file below.',
                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              _buildVideoPicker(),
              const SizedBox(height: 40),
              _buildSaveButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleItem("Tutorial / Lesson", !_isShortVideo),
          ),
          Expanded(child: _buildToggleItem("Short (60s)", _isShortVideo)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isShortVideo = label.contains("Short")),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPink : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return StreamBuilder<List<Course>>(
      stream: _dataService.streamCourses(),
      builder: (context, snapshot) {
        final courses = snapshot.data ?? [];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCourseId,
              dropdownColor: AppColors.surface,
              hint: const Text(
                'Select Course',
                style: TextStyle(color: AppColors.textGrey),
              ),
              style: const TextStyle(color: Colors.white),
              isExpanded: true,
              items: courses.map((course) {
                return DropdownMenuItem(
                  value: course.id,
                  child: Text(course.title),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCourseId = value);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHashtagInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Hashtags",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
                  controller: _hashtagController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Add tag (e.g. #flutter)",
                    hintStyle: TextStyle(color: AppColors.textGrey),
                    prefixIcon: Icon(
                      LucideIcons.hash,
                      color: AppColors.textGrey,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onSubmitted: (_) => _addHashtag(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addHashtag,
              icon: const Icon(
                LucideIcons.plusCircle,
                color: AppColors.primaryPink,
              ),
            ),
          ],
        ),
        if (_hashtags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _hashtags
                .map(
                  (tag) => Chip(
                    label: Text(
                      "#$tag",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: AppColors.primaryPink.withValues(
                      alpha: 0.2,
                    ),
                    onDeleted: () => setState(() => _hashtags.remove(tag)),
                    deleteIcon: const Icon(
                      LucideIcons.x,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Video File',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickVideo,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _videoFileName != null
                    ? AppColors.primaryPink
                    : Colors.white10,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _videoFileName != null
                      ? LucideIcons.checkCircle2
                      : LucideIcons.clapperboard,
                  size: 48,
                  color: _videoFileName != null
                      ? Colors.green
                      : AppColors.textGrey,
                ),
                const SizedBox(height: 12),
                Text(
                  _videoFileName ?? 'Tap to select video',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isUploading ? null : _saveVideo,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPink,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isUploading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              widget.lesson == null ? 'Upload Video' : 'Save Changes',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
