import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:snaplearn/core/models/user_profile.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/app_provider.dart';
import '../../core/models/course.dart';
import '../../core/services/data_service.dart';
import '../../widgets/local_media_image.dart';
import 'create_course_screen.dart';
import 'course_lessons_screen.dart';
import 'student_management_screen.dart';
import '../auth/edit_profile_screen.dart';

class InstructorDashboard extends StatelessWidget {
  const InstructorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final instructor = Provider.of<AppProvider>(context).userProfile!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "Instructor Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(instructor),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "My Courses",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateCourseScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    LucideIcons.plus,
                    size: 16,
                    color: AppColors.primaryPink,
                  ),
                  label: const Text(
                    "Create New",
                    style: TextStyle(
                      color: AppColors.primaryPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Course>>(
              stream: DataService().streamCourses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPink,
                    ),
                  );
                }

                final courses =
                    snapshot.data
                        ?.where((c) => c.instructorId == instructor.id)
                        .toList() ??
                    [];

                if (courses.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          LucideIcons.bookOpen,
                          color: AppColors.textGrey,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No courses created yet",
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    return _buildCourseAnalyticsItem(context, courses[index]);
                  },
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              "Quick Actions",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildActionButton(
                  context,
                  "Upload\nCourse",
                  LucideIcons.upload,
                  AppColors.codingPurple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateCourseScreen(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  "Profile\nSettings",
                  LucideIcons.userCog,
                  AppColors.primaryPink,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  "Course\nAnalytics",
                  LucideIcons.barChart,
                  Colors.orange.shade800,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(UserProfile instructor) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        DataService().getInstructorStudentCount(instructor.id),
        DataService().getInstructorEarnings(instructor.id),
      ]),
      builder: (context, snapshot) {
        final students = snapshot.data?[0] ?? 0;
        final earnings = snapshot.data?[1] ?? 0.0;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Total Students",
                isLoading ? "..." : students.toString(),
                LucideIcons.users,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                "Total Earnings",
                isLoading ? "..." : "\$${earnings.toStringAsFixed(1)}k",
                LucideIcons.dollarSign,
                Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseAnalyticsItem(BuildContext context, Course course) {
    bool isPublished = course.status == 'published';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CourseThumbnail(
            thumbnailPath: course.thumbnailPath,
            thumbnailUrl: course.thumbnailUrl,
            width: 50,
            height: 50,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isPublished
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPublished ? "Published" : "Draft",
                        style: TextStyle(
                          color: isPublished ? Colors.green : Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${course.enrolledCount} students",
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              LucideIcons.moreVertical,
              color: AppColors.textGrey,
            ),
            color: AppColors.surface,
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateCourseScreen(course: course),
                  ),
                );
              } else if (value == 'lessons') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseLessonsScreen(course: course),
                  ),
                );
              } else if (value == 'students') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StudentManagementScreen(course: course),
                  ),
                );
              } else if (value == 'delete') {
                _showDeleteDialog(context, course);
              } else if (value == 'toggle') {
                final newStatus = isPublished ? 'draft' : 'published';
                await DataService().updateCourseField(course.id, {
                  'status': newStatus,
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text(
                  "Edit Course",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem(
                value: 'lessons',
                child: Text(
                  "Manage Lessons",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem(
                value: 'students',
                child: Text(
                  "Manage Students",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Text(
                  isPublished ? "Unpublish" : "Publish",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Delete Course",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete '${course.title}'? This action cannot be undone.",
          style: const TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              await DataService().deleteCourse(course.id);
              if (context.mounted) Navigator.pop(context);
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

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
