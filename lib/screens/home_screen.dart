import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/app_provider.dart';
import '../core/providers/data_provider.dart';
import '../core/models/course.dart';
import '../core/models/lesson.dart';
import '../core/models/user_profile.dart';
import '../core/models/app_feature.dart';
import '../widgets/local_media_image.dart';
import 'notifications/notification_screen.dart';
import 'course_detail_screen.dart';

/// The main landing page for users after they log in.
/// Displays dynamic banners, categories, continued learning, trending micro-lessons,
/// and instructor recommendations.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DataProvider, AppProvider>(
      builder: (context, dataProvider, appProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Component displaying user's login streak
                _buildStreakCounter(context),
                const SizedBox(height: 16),
                // Dynamic carousel for featured content from the repository
                _buildBannerSlider(dataProvider.appFeatures),
                const SizedBox(height: 24),
                // Static category list (e.g. Programming, Business)
                _buildCategories(),
                const SizedBox(height: 24),
                // Shows the last course the user enrolled in, if any
                _buildContinueLearning(
                  context,
                  dataProvider.courses,
                  appProvider.userProfile?.enrolledCourseIds ?? [],
                ),
                const SizedBox(height: 24),
                // Displays trending short-form videos (TikTok style)
                _buildSectionHeader("Trending Micro-Lessons", () {}),
                _buildTrendingLessons(dataProvider.lessons),
                const SizedBox(height: 24),
                _buildSectionHeader("Recommended for You", () {}),
                _buildRecommendedCourses(
                  context,
                  dataProvider.courses,
                  appProvider.userProfile?.interests ?? [],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader("Featured Instructors", () {}),
                _buildFeaturedInstructors(dataProvider.instructors),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  final userName =
                      appProvider.currentUser?.displayName ?? 'Learner';
                  return Text(
                    "Hi, $userName!",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              Text(
                "Let's learn something new",
                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.bell, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Builds a horizontal PageView of featured banners.
  /// Content is dynamically loaded from `appFeatures` collection.
  Widget _buildBannerSlider(List<AppFeature> features) {
    if (features.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text(
            "No featured items at the moment.",
            style: TextStyle(color: AppColors.textGrey),
          ),
        ),
      );
    }
    return SizedBox(
      height: 160,
      child: PageView(
        controller: PageController(
          viewportFraction: 0.9,
        ), // Allows peeking at the next item
        children: features.map((feature) {
          return _bannerItem(
            color: _parseFeatureColor(feature.colorHex),
            title: feature.title,
            subtitle: feature.subtitle,
            imageIcon: _getIconFromName(feature.iconName),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconFromName(String name) {
    switch (name) {
      case 'code':
        return LucideIcons.code;
      case 'bookOpen':
        return LucideIcons.bookOpen;
      case 'video':
        return LucideIcons.video;
      case 'star':
        return LucideIcons.star;
      case 'briefcase':
        return LucideIcons.briefcase;
      case 'penTool':
        return LucideIcons.penTool;
      case 'megaphone':
        return LucideIcons.megaphone;
      case 'rocket':
        return LucideIcons.rocket;
      case 'zap':
        return LucideIcons.zap;
      default:
        return LucideIcons.star;
    }
  }

  Color _parseFeatureColor(String colorHex) {
    return Color(int.tryParse(colorHex, radix: 16) ?? 0xFF1E1B4B);
  }

  Widget _bannerItem({
    required Color color,
    required String title,
    required String subtitle,
    required IconData imageIcon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
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
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(imageIcon, size: 60, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildStreakCounter(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final streak = appProvider.userProfile?.streakCount ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.flame, color: Colors.orange, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$streak Day Streak!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  "Learn today to keep your streak alive!",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              "See All",
              style: TextStyle(color: AppColors.primaryPink, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {"name": "Programming", "icon": LucideIcons.code},
      {"name": "Business", "icon": LucideIcons.briefcase},
      {"name": "Design", "icon": LucideIcons.penTool},
      {"name": "Marketing", "icon": LucideIcons.megaphone},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Icon(cat["icon"] as IconData, size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  cat["name"] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContinueLearning(
    BuildContext context,
    List<Course> allCourses,
    List<String> enrolledIds,
  ) {
    if (enrolledIds.isEmpty) return const SizedBox.shrink();

    // Find the first course from the enrolled IDs that exists in allCourses
    final currentCourse = allCourses.cast<Course?>().firstWhere(
      (c) => c?.id == enrolledIds.first,
      orElse: () => null,
    );

    if (currentCourse == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Continue Learning", () {}),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CourseDetailScreen(course: currentCourse),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.codingBg,
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: courseThumbnailProvider(
                          thumbnailPath: currentCourse.thumbnailPath,
                          thumbnailUrl: currentCourse.thumbnailUrl,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentCourse.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Instructor: ${currentCourse.instructorName}",
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.4,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryPink,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    LucideIcons.playCircle,
                    color: AppColors.primaryPink,
                    size: 36,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingLessons(List<Lesson> lessons) {
    if (lessons.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "No micro-lessons available yet.",
          style: TextStyle(color: AppColors.textGrey),
        ),
      );
    }
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1516116216624-53e697fedbea?q=80&w=300&auto=format&fit=crop',
                ),
                fit: BoxFit.cover,
                opacity: 0.4,
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(LucideIcons.play, color: Colors.white, size: 32),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    lesson.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds a horizontal list of course cards filtered by the user's interests.
  Widget _buildRecommendedCourses(
    BuildContext context,
    List<Course> courses,
    List<String> userInterests,
  ) {
    // Filter courses based on user interests if they exist
    // If user has no interests, show all courses
    final filteredCourses = userInterests.isEmpty
        ? courses
        : courses.where((c) => userInterests.contains(c.category)).toList();

    if (filteredCourses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "No courses matching your interests yet.",
          style: TextStyle(color: AppColors.textGrey),
        ),
      );
    }
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredCourses.length,
        itemBuilder: (context, index) {
          final course = filteredCourses[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailScreen(course: course),
                ),
              );
            },
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      image: DecorationImage(
                        image: courseThumbnailProvider(
                          thumbnailPath: course.thumbnailPath,
                          thumbnailUrl: course.thumbnailUrl,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.star,
                              color: Colors.orange,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              course.rating.toString(),
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              "FREE",
                              style: TextStyle(
                                color: AppColors.primaryPink,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedInstructors(List<UserProfile> instructors) {
    if (instructors.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "No instructors active yet.",
          style: TextStyle(color: AppColors.textGrey),
        ),
      );
    }
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: instructors.length,
        itemBuilder: (context, index) {
          final instructor = instructors[index];
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(
                    instructor.profileImageUrl ??
                        'https://i.pravatar.cc/150?u=${instructor.id}',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  instructor.displayName.split(' ').first,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
