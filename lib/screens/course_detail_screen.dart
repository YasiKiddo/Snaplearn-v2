import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:snaplearn/core/constants/app_colors.dart';
import '../core/providers/data_provider.dart';
import '../core/providers/app_provider.dart';
import '../core/models/course.dart';
import '../core/models/lesson.dart';
import 'quiz/quiz_screen.dart';
import 'video_player_screen.dart';
import 'package:provider/provider.dart';

import '../../core/models/quiz.dart';
import '../../core/services/data_service.dart';
import '../widgets/local_media_image.dart';

/// Screen that displays detailed information about a specific course.
/// Includes the syllabus (list of lessons), instructor details, and reviews.
class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DataService _dataService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _dataService = DataService();
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
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCourseHeader(),
                  const SizedBox(height: 24),
                  _buildTabBar(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                final lessons = dataProvider.lessons
                    .where((l) => l.courseId == widget.course.id)
                    .toList();
                return TabBarView(
                  controller: _tabController,
                  // The content of the tabs below the header
                  // Uses a FutureBuilder to fetch quiz data, combined with Stream data from DataProvider
                  children: [
                    FutureBuilder<Quiz?>(
                      future: _dataService.getQuizByCourseId(widget.course.id),
                      builder: (context, quizSnapshot) {
                        return _buildSyllabusTab(lessons, quizSnapshot.data);
                      },
                    ),
                    _buildInstructorTab(),
                    _buildReviewsTab(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.bookmark, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(LucideIcons.share2, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: courseThumbnailProvider(
                thumbnailPath: widget.course.thumbnailPath,
                thumbnailUrl: widget.course.thumbnailUrl,
              ),
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.background],
                ),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.play,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.codingPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.course.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                const Icon(LucideIcons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  "${widget.course.rating} (2.4k)",
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.course.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem(LucideIcons.clock, "12h 30m"),
            _buildStatItem(
              LucideIcons.bookOpen,
              "${widget.course.lessonIds.length} Lessons",
            ),
            _buildStatItem(
              LucideIcons.users,
              "${widget.course.enrolledCount} Students",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textGrey, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primaryPink,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textGrey,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: "Syllabus"),
          Tab(text: "Instructor"),
          Tab(text: "Reviews"),
        ],
      ),
    );
  }

  Widget _buildSyllabusTab(List<Lesson> lessons, Quiz? quiz) {
    if (lessons.isEmpty && quiz == null) {
      return const Center(
        child: Text(
          "No content added yet.",
          style: TextStyle(color: AppColors.textGrey),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        ExpansionTile(
          initiallyExpanded: true,
          title: const Text(
            "Course Content",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${lessons.length} videos",
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          collapsedIconColor: Colors.white,
          iconColor: AppColors.primaryPink,
          children: lessons
              .map((lesson) => _buildLessonItem(context, lesson))
              .toList(),
        ),
        if (quiz != null) ...[
          const SizedBox(height: 16),
          _buildQuizItem(quiz, context),
        ],
      ],
    );
  }

  Widget _buildLessonItem(BuildContext context, Lesson lesson) {
    return ListTile(
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
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          LucideIcons.playCircle,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        lesson.title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: const Text(
        "Micro-lesson",
        style: TextStyle(color: AppColors.textGrey, fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          "FREE",
          style: TextStyle(
            color: Colors.green,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQuizItem(Quiz quiz, BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizScreen(quiz: quiz)),
        );
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          LucideIcons.helpCircle,
          color: Colors.orange,
          size: 20,
        ),
      ),
      title: Text(
        quiz.title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Text(
        "${quiz.questions.length} Questions",
        style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
      ),
    );
  }

  Widget _buildInstructorTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=5',
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sarah Williams",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Senior Mobile Developer @ Google",
                    style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              LucideIcons.star,
                              color: Colors.orange,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "4.9 Instructor Rating",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "About the Instructor",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "With over 10 years of experience in mobile development, I have helped thousands of students master Flutter and build production-ready applications. I specialize in clean architecture and state management.",
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=${index + 10}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Alex Johnson",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "2 weeks ago",
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        LucideIcons.star,
                        color: i < 4 ? Colors.orange : AppColors.textGrey,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Excellent course! The concepts were explained very clearly and the real-world examples really helped cement my understanding of State Management.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final appProvider = Provider.of<AppProvider>(context);
    final isEnrolled =
        appProvider.userProfile?.enrolledCourseIds.contains(widget.course.id) ??
        false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (!isEnrolled)
              const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FREE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Lifetime access",
                    style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
                ],
              ),
            if (!isEnrolled) const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (isEnrolled) {
                    // Scroll to syllabus or just show a message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("You are already enrolled!"),
                      ),
                    );
                  } else {
                    // Start Enrollment process
                    if (appProvider.isLoggedIn) {
                      // 1. Create a new list of enrolled IDs adding the new course
                      final updatedIds = List<String>.from(
                        appProvider.userProfile!.enrolledCourseIds,
                      );
                      if (!updatedIds.contains(widget.course.id)) {
                        updatedIds.add(widget.course.id);
                      }

                      // 2. Create an updated UserProfile object
                      final updatedProfile = appProvider.userProfile!.copyWith(
                        enrolledCourseIds: updatedIds,
                      );

                      // 3. Save enrollment in the application repository
                      await DataService().updateUserProfile(updatedProfile);

                      // 4. Refresh local state
                      await appProvider.refreshProfile();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Successfully Enrolled!"),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please login to enroll")),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnrolled
                      ? Colors.green
                      : AppColors.primaryPink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEnrolled ? "Enrolled & Ready" : "Enroll for Free",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
