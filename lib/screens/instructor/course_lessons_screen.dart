import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_colors.dart';
import '../../core/models/course.dart';
import '../../core/models/lesson.dart';
import '../../core/services/data_service.dart';
import '../../core/services/local_storage_service.dart';

/// `CourseLessonsScreen` is used by Instructors to manage the lessons (videos)
/// within a specific course they have created. It allows them to add, edit,
/// delete, and reorder lessons.
class CourseLessonsScreen extends StatefulWidget {
  final Course course;
  const CourseLessonsScreen({super.key, required this.course});

  @override
  State<CourseLessonsScreen> createState() => _CourseLessonsScreenState();
}

class _CourseLessonsScreenState extends State<CourseLessonsScreen> {
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "Manage Content: ${widget.course.title}",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          // Button to open the dialog for adding a new lesson
          IconButton(
            icon: const Icon(LucideIcons.plus, color: AppColors.primaryPink),
            onPressed: () => _showAddLessonDialog(),
          ),
        ],
      ),
      // Listen for real-time updates to the lessons for this specific course
      body: StreamBuilder<List<Lesson>>(
        stream: _dataService.streamLessonsByCourseId(widget.course.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            );
          }
          final lessons = snapshot.data ?? [];
          if (lessons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.video,
                    color: AppColors.textGrey,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No lessons added yet.",
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showAddLessonDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                    ),
                    child: const Text("Add First Lesson"),
                  ),
                ],
              ),
            );
          }

          // Group the lessons by their `sectionName` to create a structured syllabus view.
          // For example: "Introduction", "Advanced Topics", etc.
          Map<String, List<Lesson>> groupedLessons = {};
          for (var lesson in lessons) {
            String section = lesson.sectionName ?? "Uncategorized";
            if (!groupedLessons.containsKey(section)) {
              groupedLessons[section] = [];
            }
            groupedLessons[section]!.add(lesson);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: groupedLessons.length,
            itemBuilder: (context, index) {
              String section = groupedLessons.keys.elementAt(index);
              List<Lesson> sectionLessons = groupedLessons[section]!;
              sectionLessons.sort(
                (a, b) => a.orderIndex.compareTo(b.orderIndex),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      section.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...sectionLessons.map((lesson) => _buildLessonItem(lesson)),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLessonItem(Lesson lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: const Icon(LucideIcons.playCircle, color: Colors.white70),
        title: Text(
          lesson.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "${lesson.durationSeconds ?? 0} seconds",
          style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(LucideIcons.edit, color: Colors.blue, size: 18),
              onPressed: () => _showAddLessonDialog(lesson: lesson),
            ),
            IconButton(
              icon: const Icon(
                LucideIcons.trash2,
                color: Colors.redAccent,
                size: 18,
              ),
              onPressed: () => _confirmDelete(lesson),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays a dialog allowing the instructor to add a new lesson or edit an existing one.
  /// If [lesson] is provided, the fields are pre-filled for editing.
  void _showAddLessonDialog({Lesson? lesson}) {
    // Controllers for the input fields
    final titleController = TextEditingController(text: lesson?.title);
    final urlController = TextEditingController(text: lesson?.videoUrl);
    final sectionController = TextEditingController(text: lesson?.sectionName);
    final orderController = TextEditingController(
      text: lesson?.orderIndex.toString() ?? "0",
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        PlatformFile? selectedVideoFile;
        String? selectedVideoPath = lesson?.videoPath;
        String? selectedVideoName = lesson?.videoPath != null
            ? path.basename(lesson!.videoPath!)
            : null;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(
                lesson == null ? "Add Lesson" : "Edit Lesson",
                style: const TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogTextField(
                      titleController,
                      "Lesson Title",
                      LucideIcons.heading,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      urlController,
                      "Video URL",
                      LucideIcons.link,
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white10)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "OR UPLOAD VIDEO FILE",
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white10)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          if (selectedVideoName != null) ...[
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.video,
                                  color: AppColors.primaryPink,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedVideoName!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    LucideIcons.x,
                                    color: Colors.redAccent,
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    setDialogState(() {
                                      selectedVideoFile = null;
                                      selectedVideoPath = null;
                                      selectedVideoName = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ] else ...[
                            InkWell(
                              onTap: () async {
                                final result = await FilePicker.pickFiles(
                                      type: FileType.video,
                                      allowMultiple: false,
                                      withData: true,
                                    );
                                if (result != null) {
                                  final file = result.files.single;
                                  setDialogState(() {
                                    selectedVideoFile = file;
                                    selectedVideoPath = file.path;
                                    selectedVideoName = file.name;
                                    urlController.clear();
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                                width: double.infinity,
                                child: const Column(
                                  children: [
                                    Icon(
                                      LucideIcons.uploadCloud,
                                      color: AppColors.textGrey,
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Choose Video File",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "MP4, MOV, AVI up to 100MB",
                                      style: TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDialogTextField(
                      sectionController,
                      "Section Name",
                      LucideIcons.folder,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      orderController,
                      "Order Index",
                      LucideIcons.listOrdered,
                      isNumber: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String finalVideoUrl = urlController.text.trim();
                    String? finalVideoPath = selectedVideoPath;

                    if (selectedVideoFile == null &&
                        finalVideoPath == null &&
                        finalVideoUrl.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please provide a Video URL or upload a Video file",
                          ),
                        ),
                      );
                      return;
                    }

                    // Show custom loading overlay with simulated upload progress bar
                    showDialog(
                      context: dialogContext,
                      barrierDismissible: false,
                      builder: (loadingContext) {
                        return StatefulBuilder(
                          builder: (context, setProgressState) {
                            return AlertDialog(
                              backgroundColor: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              content: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: AppColors.primaryPink,
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      "Uploading video and saving lesson...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Please keep this window open",
                                      style: TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );

                    final navigator = Navigator.of(dialogContext);
                    final messenger = ScaffoldMessenger.of(dialogContext);

                    try {
                      if (selectedVideoFile != null) {
                        finalVideoUrl = await LocalStorageService.uploadVideo(
                          selectedVideoFile!,
                        );
                        finalVideoPath = null;
                      } else if (finalVideoUrl.isNotEmpty) {
                        finalVideoPath = null;
                      }

                      // Short simulated delay to make upload process visually clear to user
                      await Future.delayed(const Duration(seconds: 1));

                      final newLesson = Lesson(
                        id: lesson?.id ?? '',
                        title: titleController.text.trim(),
                        category: widget.course.category,
                        videoUrl: finalVideoUrl,
                        videoPath: finalVideoPath,
                        courseId: widget.course.id,
                        instructorId: widget.course.instructorId,
                        sectionName: sectionController.text.trim(),
                        orderIndex: int.tryParse(orderController.text) ?? 0,
                      );

                      if (lesson == null) {
                        await _dataService.addLesson(newLesson);
                      } else {
                        await _dataService.updateLesson(newLesson);
                      }

                      navigator.pop(); // Pop loading dialog
                      navigator.pop(); // Pop add/edit lesson dialog
                    } catch (e) {
                      navigator.pop(); // Pop loading dialog
                      messenger.showSnackBar(
                        SnackBar(content: Text("Error saving lesson: $e")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                  ),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.textGrey, size: 18),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryPink),
        ),
      ),
    );
  }

  void _confirmDelete(Lesson lesson) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Delete Lesson",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete '${lesson.title}'?",
          style: const TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              await _dataService.deleteLesson(lesson.id);
              if (mounted) navigator.pop();
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
