import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/data_provider.dart';
import '../core/models/course.dart';
import '../core/models/lesson.dart';
import '../widgets/local_media_image.dart';
import 'course_detail_screen.dart';
import 'video_player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _recentSearches = [
    "Flutter State Management",
    "Business English",
    "UI/UX Design basics",
  ];

  final List<String> _trendingSearches = [
    "Python for Beginners",
    "Digital Marketing",
    "Public Speaking",
    "Machine Learning",
    "React vs Angular",
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            Expanded(
              child: _searchController.text.isEmpty
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRecentSearches(),
                          const SizedBox(height: 30),
                          _buildTrendingSearches(),
                          const SizedBox(height: 30),
                          _buildBrowseCategories(),
                        ],
                      ),
                    )
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: "Search courses, videos, mentors...",
                  hintStyle: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    color: AppColors.textGrey,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      LucideIcons.mic,
                      color: AppColors.primaryPink,
                    ),
                    onPressed: () {}, // Voice search action
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(
              LucideIcons.slidersHorizontal,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Searches",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Clear All",
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: _recentSearches.map((search) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.clock,
                    color: AppColors.textGrey,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    search,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTrendingSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              LucideIcons.trendingUp,
              color: AppColors.primaryPink,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              "Trending Now",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: _trendingSearches.map((search) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                search,
                style: const TextStyle(
                  color: AppColors.primaryPink,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBrowseCategories() {
    final categories = [
      {
        "name": "Programming",
        "color": AppColors.codingPurple,
        "icon": LucideIcons.code,
      },
      {
        "name": "Business",
        "color": AppColors.businessGold,
        "icon": LucideIcons.briefcase,
      },
      {
        "name": "Design",
        "color": Colors.pink.shade900,
        "icon": LucideIcons.penTool,
      },
      {
        "name": "Marketing",
        "color": Colors.orange.shade900,
        "icon": LucideIcons.megaphone,
      },
      {
        "name": "English",
        "color": AppColors.englishTeal,
        "icon": LucideIcons.languages,
      },
      {
        "name": "Finance",
        "color": Colors.green.shade900,
        "icon": LucideIcons.pieChart,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Browse Categories",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return Container(
              decoration: BoxDecoration(
                color: cat["color"] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat["icon"] as IconData, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    cat["name"] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    final dataProvider = Provider.of<DataProvider>(context);
    final query = _searchController.text;
    final courses = dataProvider.searchCourses(query);
    final lessons = dataProvider.searchLessons(query);

    if (courses.isEmpty && lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.searchX,
              size: 64,
              color: AppColors.textGrey,
            ),
            const SizedBox(height: 16),
            Text(
              "No results for \"$query\"",
              style: const TextStyle(color: AppColors.textGrey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (courses.isNotEmpty) ...[
          const Text(
            "Courses",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...courses.map((course) => _buildCourseResult(course)),
          const SizedBox(height: 24),
        ],
        if (lessons.isNotEmpty) ...[
          const Text(
            "Tutorials",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...lessons.map((lesson) => _buildLessonResult(lesson)),
        ],
      ],
    );
  }

  Widget _buildCourseResult(Course course) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
      },
      leading: Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: courseThumbnailProvider(
              thumbnailPath: course.thumbnailPath,
              thumbnailUrl: course.thumbnailUrl,
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        course.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        course.category,
        style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
      ),
      trailing: const Icon(
        LucideIcons.chevronRight,
        color: AppColors.textGrey,
        size: 16,
      ),
    );
  }

  Widget _buildLessonResult(Lesson lesson) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(lesson: lesson),
          ),
        );
      },
      leading: Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          LucideIcons.playCircle,
          color: AppColors.primaryPink,
          size: 20,
        ),
      ),
      title: Text(
        lesson.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        lesson.category,
        style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
      ),
      trailing: const Icon(
        LucideIcons.chevronRight,
        color: AppColors.textGrey,
        size: 16,
      ),
    );
  }
}
