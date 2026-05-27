import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:snaplearn/core/models/user_profile.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/data_provider.dart';
import '../core/models/lesson.dart';
import '../widgets/video_player_widget.dart';
import '../core/services/data_service.dart';
import '../core/providers/app_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PageController _pageController = PageController();
  final DataService _dataService = DataService();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleLike(Lesson lesson) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (!appProvider.isLoggedIn) return;
    await _dataService.toggleLikeLesson(appProvider.userProfile!.id, lesson);
  }

  Future<void> _handleFollow(String instructorId) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (!appProvider.isLoggedIn) return;
    final messenger = ScaffoldMessenger.of(context);
    await _dataService.toggleFollowInstructor(
      appProvider.userProfile!.id,
      instructorId,
    );
    if (!mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text("Follow updated")));
  }

  Future<void> _handleSave(String lessonId) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    if (!appProvider.isLoggedIn) return;
    final messenger = ScaffoldMessenger.of(context);
    await _dataService.toggleSaveLesson(appProvider.userProfile!.id, lessonId);
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text("Saved lessons updated")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        if (dataProvider.isLoadingLessons) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            ),
          );
        }

        final lessons = dataProvider.lessons
            .where(
              (lesson) => lesson.isFeedVideo && lesson.status == 'published',
            )
            .toList();
        lessons.sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });

        if (lessons.isEmpty) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                "No lessons found.",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              return _buildVideoItem(lessons[index], dataProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildVideoItem(Lesson lesson, DataProvider dataProvider) {
    // Dynamic lookups
    final instructor = dataProvider.instructors.firstWhere(
      (u) => u.id == lesson.instructorId,
      orElse: () =>
          UserProfile(id: 'unknown', displayName: 'Instructor', email: ''),
    );
    final String instructorName = instructor.displayName.isNotEmpty
        ? instructor.displayName
        : "Instructor";
    final String avatar =
        instructor.profileImageUrl ??
        "https://ui-avatars.com/api/?name=${Uri.encodeComponent(instructorName)}&background=random";

    Color categoryColor = AppColors.primaryPink;
    switch (lesson.category.toLowerCase()) {
      case 'coding':
        categoryColor = AppColors.codingPurple;
        break;
      case 'design':
        categoryColor = AppColors.englishTeal;
        break;
      case 'business':
        categoryColor = AppColors.businessGold;
        break;
    }

    return Stack(
      children: [
        // Video Player
        Positioned.fill(
          child: VideoPlayerWidget(
            videoUrl: lesson.videoUrl,
            videoPath: lesson.videoPath,
          ),
        ),

        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Header (Category & Search)
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.tag,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lesson.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.search, color: Colors.white, size: 28),
              ],
            ),
          ),
        ),

        // Bottom Content Area
        Positioned(
          bottom: 20,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(avatar),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    instructorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () =>
                        _handleFollow(lesson.instructorId ?? "admin_1"),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Follow",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                lesson.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lesson.description.isNotEmpty
                    ? lesson.description
                    : "Learn how to master this topic! Watch till the end for a pro tip.",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (lesson.hashtags.isNotEmpty)
                    ...lesson.hashtags.take(2).map((tag) => _buildTag("#$tag")),
                  if (lesson.hashtags.isEmpty) _buildTag(lesson.category),
                  _buildTag("${lesson.durationSeconds ?? 60} Sec"),
                ],
              ),
            ],
          ),
        ),

        // Right Interaction Column
        Positioned(
          bottom: 40,
          right: 16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildInteractionButton(
                LucideIcons.heart,
                lesson.likesCount.toString(),
                onTap: () => _handleLike(lesson),
                color: Colors.redAccent,
              ),
              _buildInteractionButton(
                LucideIcons.messageCircle,
                lesson.commentsCount.toString(),
              ),
              _buildInteractionButton(
                LucideIcons.bookmark,
                "Save",
                onTap: () => _handleSave(lesson.id),
              ),
              _buildInteractionButton(LucideIcons.share2, "Share"),
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryPink,
                ),
                child: const Icon(
                  LucideIcons.music,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),

        // Video Progress Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: LinearProgressIndicator(
            value: 0.3,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionButton(
    IconData icon,
    String label, {
    VoidCallback? onTap,
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
