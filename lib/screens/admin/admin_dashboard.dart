import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:snaplearn/core/models/activity_log.dart';
import 'package:snaplearn/core/providers/app_provider.dart';
import 'package:snaplearn/core/providers/data_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/lesson.dart';
import '../../core/models/course.dart';
import '../../core/services/data_service.dart';
import 'add_video_screen.dart';
import 'add_course_screen.dart';
import 'add_quiz_screen.dart';
import 'user_management_screen.dart';
import 'instructor_management_screen.dart';
import 'moderation_screen.dart';
import '../../core/models/quiz.dart';
import 'add_feature_screen.dart';
import '../../core/models/app_feature.dart';
import '../../widgets/local_media_image.dart';
import '../video_player_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  final DataService _dataService = DataService();
  late TabController _tabController;
  late TabController _courseSubTabController;
  late TabController _lessonSubTabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _courseSubTabController = TabController(length: 2, vsync: this);
    _lessonSubTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _courseSubTabController.dispose();
    _lessonSubTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryPink,
          labelColor: AppColors.primaryPink,
          unselectedLabelColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Students'),
            Tab(text: 'Instructors'),
            Tab(text: 'Courses'),
            Tab(text: 'Videos'),
            Tab(text: 'Quizzes'),
            Tab(text: 'Moderation'),
            Tab(text: 'Features'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: Colors.redAccent),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await Provider.of<AppProvider>(context, listen: false).logout();
              if (mounted) {
                navigator.pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.plus, color: AppColors.primaryPink),
            onPressed: () {
              if (_tabController.index == 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddVideoScreen(),
                  ),
                );
              } else if (_tabController.index == 5) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddQuizScreen(),
                  ),
                );
              } else if (_tabController.index == 7) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddFeatureScreen(),
                  ),
                );
              } else if (_tabController.index == 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Courses can only be created by Instructors"),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Go to a management tab to add content"),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          const StudentManagementScreen(),
          const InstructorManagementScreen(),
          _buildCourseList(),
          _buildLessonList(),
          _buildQuizList(),
          const ModerationScreen(),
          _buildFeatureList(),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    return StreamBuilder<List<AppFeature>>(
      stream: _dataService.streamAppFeatures(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPink),
          );
        }
        final features = snapshot.data ?? [];
        if (features.isEmpty) {
          return _buildEmptyState(
            'No feature banners found',
            'Create Banner',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFeatureScreen(),
                ),
              );
            },
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _buildListItem(
              title: feature.title,
              subtitle: feature.subtitle,
              icon: LucideIcons.star,
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddFeatureScreen(feature: feature),
                  ),
                );
              },
              onDelete: () => _showDeleteDialog(
                feature.id,
                isCourse: false,
                isFeature: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCourseList() {
    return Column(
      children: [
        TabBar(
          controller: _courseSubTabController,
          indicatorColor: AppColors.primaryPink,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Published'),
            Tab(text: 'Pending'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _courseSubTabController,
            children: [
              _buildFilteredCourseList('published'),
              _buildFilteredCourseList('pending'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilteredCourseList(String status) {
    return StreamBuilder<List<Course>>(
      stream: _dataService.streamCoursesByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPink),
          );
        }
        final courses = snapshot.data ?? [];
        if (courses.isEmpty) {
          return _buildEmptyState('No $status courses found', '', () {});
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return _buildCourseManagementItem(course);
          },
        );
      },
    );
  }

  Widget _buildCourseManagementItem(Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: course.isFeatured
              ? AppColors.primaryPink.withValues(alpha: 0.3)
              : Colors.white10,
        ),
      ),
      child: ListTile(
        leading: CourseThumbnail(
          thumbnailPath: course.thumbnailPath,
          thumbnailUrl: course.thumbnailUrl,
          width: 50,
          height: 50,
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          course.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '\$${course.price} • ${course.category}',
          style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (course.status == 'pending')
              IconButton(
                icon: const Icon(
                  LucideIcons.check,
                  color: Colors.green,
                  size: 20,
                ),
                onPressed: () => _dataService.updateCourseField(course.id, {
                  'status': 'published',
                }),
              ),
            IconButton(
              icon: Icon(
                LucideIcons.star,
                color: course.isFeatured ? Colors.amber : AppColors.textGrey,
                size: 20,
              ),
              onPressed: () => _dataService.updateCourseField(course.id, {
                'isFeatured': !course.isFeatured,
              }),
            ),
            IconButton(
              icon: const Icon(LucideIcons.edit, color: Colors.blue, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCourseScreen(course: course),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
              onPressed: () => _showDeleteDialog(course.id, isCourse: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonList() {
    return Column(
      children: [
        TabBar(
          controller: _lessonSubTabController,
          indicatorColor: AppColors.primaryPink,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Published'),
            Tab(text: 'Pending'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _lessonSubTabController,
            children: [
              _buildFilteredLessonList('published'),
              _buildFilteredLessonList('pending'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilteredLessonList(String status) {
    return StreamBuilder<List<Lesson>>(
      stream: _dataService.streamLessonsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPink),
          );
        }
        final lessons = snapshot.data ?? [];
        if (lessons.isEmpty) {
          return _buildEmptyState(
            'No $status videos found',
            'Upload Video',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddVideoScreen()),
              );
            },
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return _buildLessonManagementItem(lesson);
          },
        );
      },
    );
  }

  Widget _buildLessonManagementItem(Lesson lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: lesson.isTrending
              ? Colors.orange.withValues(alpha: 0.3)
              : Colors.white10,
        ),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(lesson: lesson),
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryPink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(LucideIcons.video, color: AppColors.primaryPink),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${lesson.category} • ${lesson.likesCount} Likes',
          style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lesson.status == 'pending')
              IconButton(
                icon: const Icon(
                  LucideIcons.check,
                  color: Colors.green,
                  size: 20,
                ),
                onPressed: () => _dataService.updateLessonField(lesson.id, {
                  'status': 'published',
                }),
              ),
            IconButton(
              icon: Icon(
                LucideIcons.zap,
                color: lesson.isTrending ? Colors.orange : AppColors.textGrey,
                size: 20,
              ),
              onPressed: () => _dataService.updateLessonField(lesson.id, {
                'isTrending': !lesson.isTrending,
              }),
            ),
            IconButton(
              icon: const Icon(LucideIcons.edit, color: Colors.blue, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVideoScreen(lesson: lesson),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
              onPressed: () => _showDeleteDialog(lesson.id, isCourse: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizList() {
    return StreamBuilder<List<Course>>(
      stream: _dataService.streamCourses(),
      builder: (context, snapshot) {
        final courses = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return FutureBuilder<Quiz?>(
              future: _dataService.getQuizByCourseId(course.id),
              builder: (context, quizSnapshot) {
                final quiz = quizSnapshot.data;
                return _buildListItem(
                  title: quiz?.title ?? 'No Quiz for ${course.title}',
                  subtitle: quiz != null
                      ? '${quiz.questions.length} Questions'
                      : 'No quiz added by instructor',
                  icon: LucideIcons.clipboardCheck,
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddQuizScreen(courseId: course.id, quiz: quiz),
                      ),
                    );
                  },
                  onDelete: () {
                    if (quiz != null) {
                      // Implementation for deleting quiz would go here
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(
    String message,
    String btnText,
    VoidCallback onPressed,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.folderX, size: 64, color: AppColors.textGrey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 18),
          ),
          const SizedBox(height: 16),
          if (btnText.isNotEmpty)
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
              ),
              child: Text(btnText),
            ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryPink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryPink),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textGrey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(LucideIcons.edit, color: Colors.blue, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    String id, {
    required bool isCourse,
    bool isFeature = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          isFeature
              ? 'Delete Banner'
              : (isCourse ? 'Delete Course' : 'Delete Video'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this ${isFeature ? 'banner' : (isCourse ? 'course' : 'video')}?',
          style: const TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              if (isFeature) {
                _dataService.deleteAppFeature(id);
              } else if (isCourse) {
                _dataService.deleteCourse(id);
              } else {
                _dataService.deleteLesson(id);
              }
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final dataProvider = Provider.of<DataProvider>(context);
    final totalCourses = dataProvider.courses.length;

    return FutureBuilder<Map<String, int>>(
      future:
          Future.wait([
            _dataService.getTotalStudentsCount(),
            _dataService.getTotalInstructorsCount(),
            _dataService.getTotalEnrollmentsCount(),
          ]).then(
            (results) => {
              'students': results[0],
              'instructors': results[1],
              'enrollments': results[2],
            },
          ),
      builder: (context, snapshot) {
        final stats =
            snapshot.data ??
            {'students': 0, 'instructors': 0, 'enrollments': 0};
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Platform Snapshot",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primaryPink),
              )
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(
                    "Total Students",
                    stats['students'].toString(),
                    LucideIcons.users,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    "Instructors",
                    stats['instructors'].toString(),
                    LucideIcons.userCheck,
                    Colors.purple,
                  ),
                  _buildStatCard(
                    "Total Courses",
                    totalCourses.toString(),
                    LucideIcons.bookOpen,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    "Enrollments",
                    stats['enrollments'].toString(),
                    LucideIcons.graduationCap,
                    Colors.green,
                  ),
                  _buildStatCard(
                    "Earnings",
                    "\$${stats['enrollments']! * 49}",
                    LucideIcons.dollarSign,
                    Colors.amber,
                  ), // Estimated at $49/course
                  _buildStatCard(
                    "Active Now",
                    (stats['students']! ~/ 10 + 1).toString(),
                    LucideIcons.activity,
                    Colors.redAccent,
                  ),
                ],
              ),
            const SizedBox(height: 32),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Activity",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Real-time",
                  style: TextStyle(color: AppColors.primaryPink, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<ActivityLog>>(
              stream: _dataService.streamRecentActivities(),
              builder: (context, activitySnapshot) {
                if (activitySnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPink,
                    ),
                  );
                }
                final activities = activitySnapshot.data ?? [];
                if (activities.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        "No recent activity",
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _buildActivityItem(
                      activity.title,
                      activity.subtitle,
                      _formatTimestamp(activity.timestamp),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return "Just now";
    if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
    if (difference.inHours < 24) return "${difference.inHours}h ago";
    return "${difference.inDays}d ago";
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
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.bell,
              color: AppColors.primaryPink,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: Colors.white24, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
