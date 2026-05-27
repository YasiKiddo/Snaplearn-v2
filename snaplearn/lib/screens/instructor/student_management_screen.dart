import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/course.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/data_service.dart';

class StudentManagementScreen extends StatefulWidget {
  final Course course;
  const StudentManagementScreen({super.key, required this.course});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "Students: ${widget.course.title}",
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: StreamBuilder<List<UserProfile>>(
        stream: _dataService.streamStudentsEnrolledInCourse(widget.course.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            );
          }
          final students = snapshot.data ?? [];
          if (students.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.users, color: AppColors.textGrey, size: 64),
                  SizedBox(height: 16),
                  Text(
                    "No students enrolled yet.",
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return _buildStudentItem(student);
            },
          );
        },
      ),
    );
  }

  Widget _buildStudentItem(UserProfile student) {
    // Calculate progress (mock logic based on completedLessonIds)
    double progress = 0.0;
    if (widget.course.lessonIds.isNotEmpty) {
      int completedInCourse = student.completedLessonIds
          .where((id) => widget.course.lessonIds.contains(id))
          .length;
      progress = completedInCourse / widget.course.lessonIds.length;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              student.profileImageUrl ??
                  'https://i.pravatar.cc/150?u=${student.id}',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryPink,
                    ),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${(progress * 100).toInt()}% Complete",
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.userMinus,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: () => _confirmRemove(student),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(UserProfile student) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Remove Student",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to remove '${student.displayName}' from this course?",
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
              // Implementation for removing student
              await _dataService.removeStudentFromCourse(
                student.id,
                widget.course.id,
              );
              if (mounted) navigator.pop();
            },
            child: const Text(
              "Remove",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
