import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:snaplearn/core/constants/app_colors.dart';
import 'package:snaplearn/core/models/lesson.dart';
import 'package:snaplearn/core/services/data_service.dart';

/// `ModerationScreen` is accessible only by Admin users.
/// It provides an interface to review user-reported videos and comments,
/// allowing admins to dismiss the reports or delete the violating content.
class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen>
    with TickerProviderStateMixin {
  final DataService _dataService = DataService();

  // Controller to handle switching between the "Videos" and "Comments" tabs
  late TabController _modTabController;

  @override
  void initState() {
    super.initState();
    // Initialize the tab controller with 2 tabs
    _modTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _modTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _modTabController,
          indicatorColor: AppColors.primaryPink,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: "Reported Videos"),
            Tab(text: "Reported Comments"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _modTabController,
            children: [_buildReportedLessons(), _buildReportedComments()],
          ),
        ),
      ],
    );
  }

  /// Builds the list of reported videos by listening to the content stream.
  Widget _buildReportedLessons() {
    return StreamBuilder<List<Lesson>>(
      stream: _dataService.streamReportedLessons(),
      builder: (context, snapshot) {
        // Show loading indicator while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPink),
          );
        }

        final lessons = snapshot.data ?? [];

        // Handle empty state if there are no reports
        if (lessons.isEmpty) {
          return const Center(
            child: Text(
              "No reported videos",
              style: TextStyle(color: AppColors.textGrey),
            ),
          );
        }

        // Display reports in a scrollable list
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return _buildReportCard(
              title: lesson.title,
              subtitle: "Reports: ${lesson.reportCount}",
              type: "VIDEO",
              // Action: Completely delete the video from the database
              onRemove: () => _dataService.deleteLesson(lesson.id),
              // Action: Reset the report count to 0, essentially ignoring the reports
              onDismiss: () =>
                  _dataService.updateLessonField(lesson.id, {'reportCount': 0}),
            );
          },
        );
      },
    );
  }

  Widget _buildReportedComments() {
    return StreamBuilder<List<ReportedComment>>(
      stream: _dataService.streamReportedComments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPink),
          );
        }
        final comments = snapshot.data ?? [];
        if (comments.isEmpty) {
          return const Center(
            child: Text(
              "No reported comments",
              style: TextStyle(color: AppColors.textGrey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            final data = {
              'text': comment.text,
              'userName': comment.userName,
              'reportCount': comment.reportCount,
              'userId': comment.userId,
            };
            final commentId = comment.id;
            return _buildReportCard(
              title: (data['text'] as String?) ?? 'No content',
              subtitle:
                  "By: ${data['userName'] ?? 'Unknown'} • Reports: ${data['reportCount'] ?? 0}",
              type: "COMMENT",
              onRemove: () => _dataService.deleteComment(commentId),
              onDismiss: () => _dataService.dismissCommentReport(commentId),
              onBanUser: () => _showBanDialog(data['userId'] as String?),
            );
          },
        );
      },
    );
  }

  /// Reusable UI component for displaying a single report.
  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required String type, // "VIDEO" or "COMMENT"
    required VoidCallback onRemove,
    required VoidCallback onDismiss,
    VoidCallback? onBanUser, // Optional callback if we want to ban the author
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  type,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                LucideIcons.alertTriangle,
                color: Colors.orange,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onBanUser != null)
                TextButton.icon(
                  onPressed: onBanUser,
                  icon: const Icon(
                    LucideIcons.userX,
                    size: 16,
                    color: Colors.orange,
                  ),
                  label: const Text(
                    "Ban User",
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
              TextButton.icon(
                onPressed: onDismiss,
                icon: const Icon(
                  LucideIcons.check,
                  size: 16,
                  color: Colors.green,
                ),
                label: const Text(
                  "Dismiss",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onRemove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  foregroundColor: Colors.red,
                  elevation: 0,
                ),
                icon: const Icon(LucideIcons.trash2, size: 16),
                label: const Text("Remove", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before banning a user.
  /// Banning a user sets `isBlocked` to true in their profile.
  void _showBanDialog(String? userId) {
    if (userId == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Ban User"),
        content: const Text(
          "Are you sure you want to ban this user? They will lose access to the platform.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _dataService.updateUserField(userId, {'isBlocked': true});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User has been banned.")),
              );
            },
            child: const Text("Ban", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
