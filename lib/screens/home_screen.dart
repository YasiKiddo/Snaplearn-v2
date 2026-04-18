import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/action_button.dart';
import '../widgets/feature_card.dart';
import 'feed_screen.dart';
import '../widgets/video_preview_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/icons/zap.png',
              width: 20,
              height: 20,
              color: AppColors.primaryPink,
            ),
            const SizedBox(width: 8),
            const Text(
              "SnapLearn",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ActionButton(
              text: "Go to Feed",
              onPressed: () {},
              isSmall: true,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Video Preview
            VideoPreviewCard(),

            const SizedBox(height: 40),

            // Badge
            _buildBadge(),

            const SizedBox(height: 20),

            // Title
            _buildHeroTitle(),

            const SizedBox(height: 20),

            // Description
            Text(
              "Swipe through bite-sized video lessons in coding, business, and English. Like TikTok — but every scroll makes you smarter.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // Button
            ActionButton(
              text: "Start Learning",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedScreen()),
                );
              },
            ),

            const SizedBox(height: 60),

            // ✅ Stats Section (NOW INSIDE COLUMN)
            _buildStatsGrid(),

            const SizedBox(height: 60),

            // Features Title
            const Text(
              "Learning, reimagined",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Feature Cards
            FeatureCard(
              iconPath: 'assets/icons/zap.png',
              title: "60-second lessons",
              description:
                  "Every lesson is designed to fit in under a minute. No fluff, pure knowledge.",
            ),

            FeatureCard(
              iconPath: 'assets/icons/circle-play.png',
              title: "Swipe to learn",
              description:
                  "Scroll through your feed just like TikTok — but every swipe makes you smarter.",
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/timer.png',
            width: 14,
            height: 14,
            color: AppColors.primaryPink,
          ),
          const SizedBox(width: 6),
          Text(
            "30-60 second lessons",
            style: TextStyle(
              color: AppColors.primaryPink,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
        children: [
          const TextSpan(text: "Learn anything\nin "),
          TextSpan(
            text: "60 seconds",
            style: TextStyle(color: AppColors.primaryPink),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      children: [
        _statItem("50K+", "Learners"),
        _statItem("740+", "Lessons"),
        _statItem("60s", "Per lesson"),
        _statItem("4.9 ⭐", "Rating"),
      ],
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
      ],
    );
  }
}
