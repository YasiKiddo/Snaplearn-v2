import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:snaplearn/core/constants/app_colors.dart';
import 'package:snaplearn/core/models/user_profile.dart';
import 'package:snaplearn/core/services/data_service.dart';

class InstructorManagementScreen extends StatefulWidget {
  const InstructorManagementScreen({super.key});

  @override
  State<InstructorManagementScreen> createState() =>
      _InstructorManagementScreenState();
}

class _InstructorManagementScreenState extends State<InstructorManagementScreen>
    with SingleTickerProviderStateMixin {
  final DataService _dataService = DataService();
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _subTabController,
          indicatorColor: AppColors.primaryPink,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textGrey,
          tabs: const [
            Tab(text: "Active Instructors"),
            Tab(text: "Pending Requests"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildInstructorList(pendingOnly: false),
              _buildInstructorList(pendingOnly: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructorList({required bool pendingOnly}) {
    return StreamBuilder<List<UserProfile>>(
      stream: _dataService.streamInstructors(pendingOnly: pendingOnly),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryPink),
          );
        }
        final instructors = snapshot.data ?? [];
        if (instructors.isEmpty) {
          return Center(
            child: Text(
              pendingOnly ? "No pending requests" : "No active instructors",
              style: const TextStyle(color: AppColors.textGrey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: instructors.length,
          itemBuilder: (context, index) {
            final instructor = instructors[index];
            return _buildInstructorCard(instructor, pendingOnly);
          },
        );
      },
    );
  }

  Widget _buildInstructorCard(UserProfile instructor, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.primaryPink.withValues(alpha: 0.1),
          child: const Icon(
            LucideIcons.userCheck,
            color: AppColors.primaryPink,
          ),
        ),
        title: Text(
          instructor.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              instructor.email,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatIcon(
                  LucideIcons.dollarSign,
                  instructor.totalEarnings.toStringAsFixed(2),
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildStatIcon(
                  LucideIcons.bookOpen,
                  instructor.enrolledCourseIds.length.toString(),
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
        trailing: isPending
            ? _buildPendingActions(instructor)
            : _buildActiveActions(instructor),
      ),
    );
  }

  Widget _buildStatIcon(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingActions(UserProfile instructor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(LucideIcons.check, color: Colors.green),
          onPressed: () => _dataService.updateInstructorApplication(
            instructor.id,
            'approved',
          ),
        ),
        IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.red),
          onPressed: () => _dataService.updateInstructorApplication(
            instructor.id,
            'rejected',
          ),
        ),
      ],
    );
  }

  Widget _buildActiveActions(UserProfile instructor) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, color: AppColors.textGrey),
      color: AppColors.surface,
      onSelected: (value) {
        if (value == 'suspend') {
          _dataService.updateUserField(instructor.id, {
            'isBlocked': !instructor.isBlocked,
          });
        } else if (value == 'remove') {
          _dataService.updateUserField(instructor.id, {'role': 'student'});
        } else if (value == 'verify') {
          _dataService.updateUserField(instructor.id, {
            'isVerified': !instructor.isVerified,
          });
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'verify',
          child: Row(
            children: [
              Icon(
                LucideIcons.userCheck,
                color: instructor.isVerified ? Colors.blue : Colors.white,
                size: 18,
              ),
              SizedBox(width: 12),
              Text(
                instructor.isVerified ? "Unverify" : "Verify Instructor",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'suspend',
          child: Row(
            children: [
              Icon(
                LucideIcons.lock,
                color: instructor.isBlocked ? Colors.green : Colors.orange,
                size: 18,
              ),
              SizedBox(width: 12),
              Text(
                instructor.isBlocked ? "Unsuspend" : "Suspend Instructor",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(LucideIcons.userMinus, color: Colors.red, size: 18),
              SizedBox(width: 12),
              Text(
                "Remove Instructor Role",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
