import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/app_provider.dart';
import '../core/providers/data_provider.dart';
import '../core/models/course.dart';
import '../core/models/lesson.dart';
import 'course_detail_screen.dart';
import 'video_player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "My Library",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryPink,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textGrey,
          dividerColor: Colors.white10,
          tabs: const [
            Tab(text: "Courses"),
            Tab(text: "Videos"),
            Tab(text: "Downloads"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCoursesTab(),
          _buildVideosTab(),
          _buildDownloadsTab(),
          _buildCompletedTab(),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    final appProvider = Provider.of<AppProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final enrolledIds = appProvider.userProfile?.enrolledCourseIds ?? [];
    final enrolledCourses = dataProvider.courses
        .where((c) => enrolledIds.contains(c.id))
        .toList();

    if (enrolledCourses.isEmpty) {
      return _buildEmptyState("No enrolled courses yet.", "Explore Courses");
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader("Enrolled Courses (${enrolledCourses.length})"),
        ...enrolledCourses.map((c) => _buildSavedCourseItem(c)),
      ],
    );
  }

  Widget _buildVideosTab() {
    final appProvider = Provider.of<AppProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final savedIds = appProvider.userProfile?.savedLessonIds ?? [];
    final savedVideos = dataProvider.lessons
        .where((l) => savedIds.contains(l.id))
        .toList();

    if (savedVideos.isEmpty) {
      return _buildEmptyState("No saved videos yet.", "Go to Feed");
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader("Watch Later - Tutorials (${savedVideos.length})"),
        ...savedVideos.map((l) => _buildSavedVideoItem(l)),
      ],
    );
  }

  Widget _buildEmptyState(String message, String btnText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.folderX, size: 64, color: AppColors.textGrey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _buildDownloadsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: const Row(
            children: [
              Icon(
                LucideIcons.hardDrive,
                color: AppColors.primaryPink,
                size: 24,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Storage Used",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "1.2 GB / 5.0 GB limit",
                      style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader("Offline Courses"),
        _buildDownloadedItem(
          "Complete Flutter Developer Bootcamp",
          "15 Lessons • 450 MB",
        ),
        _buildDownloadedItem("Dart Programming Language", "8 Lessons • 120 MB"),
      ],
    );
  }

  Widget _buildCompletedTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader("Certificates Earned (3)"),
        _buildCertificateItem(
          "Flutter State Management",
          "Completed on Oct 12, 2023",
        ),
        _buildCertificateItem("Intro to UI/UX", "Completed on Sep 05, 2023"),
        _buildCertificateItem("Python Basics", "Completed on Aug 20, 2023"),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSavedCourseItem(Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        ),
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.codingPurple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            LucideIcons.bookOpen,
            color: AppColors.codingPurple,
          ),
        ),
        title: Text(
          course.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "${course.category} • Lifetime Access",
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          color: AppColors.textGrey,
        ),
      ),
    );
  }

  Widget _buildSavedVideoItem(Lesson lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(lesson: lesson),
          ),
        ),
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              LucideIcons.playCircle,
              color: AppColors.primaryPink,
              size: 24,
            ),
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "${lesson.category} • saved",
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ),
        trailing: const Icon(
          LucideIcons.moreVertical,
          color: AppColors.textGrey,
        ),
      ),
    );
  }

  Widget _buildDownloadedItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(LucideIcons.download, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ),
        trailing: const Icon(LucideIcons.trash2, color: Colors.redAccent),
      ),
    );
  }

  Widget _buildCertificateItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232526), Color(0xFF414345)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(LucideIcons.award, color: Colors.amber, size: 40),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(0, 36),
          ),
          child: const Text(
            "View",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
