import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:snaplearn/core/constants/app_colors.dart';
import 'package:snaplearn/core/models/user_profile.dart';
import 'package:snaplearn/core/services/data_service.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final DataService _dataService = DataService();
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: StreamBuilder<List<UserProfile>>(
            stream: _dataService.streamStudents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryPink,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final users = snapshot.data ?? [];
              final filteredUsers = users.where((u) {
                final nameMatch = u.displayName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
                final emailMatch = u.email.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
                return nameMatch || emailMatch;
              }).toList();

              if (filteredUsers.isEmpty) {
                return const Center(
                  child: Text(
                    "No students found",
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _buildUserCard(user);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Search users by name or email...",
          hintStyle: const TextStyle(color: AppColors.textGrey),
          prefixIcon: const Icon(LucideIcons.search, color: AppColors.textGrey),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    LucideIcons.x,
                    color: AppColors.textGrey,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = "";
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: user.isBlocked
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.white10,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryPink.withValues(alpha: 0.1),
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null
              ? Text(
                  user.displayName.isNotEmpty
                      ? user.displayName[0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                    color: AppColors.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isVerified)
              const Icon(
                LucideIcons.checkCircle2,
                color: Colors.blue,
                size: 16,
              ),
            if (user.isBlocked)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "Blocked",
                  style: TextStyle(color: Colors.red, fontSize: 10),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildChip(user.role.toUpperCase(), Colors.purple),
                const SizedBox(width: 4),
                _buildChip(user.subscriptionType.toUpperCase(), Colors.green),
              ],
            ),
          ],
        ),
        trailing: _buildPopupMenu(user),
        onTap: () => _showUserDetails(user),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPopupMenu(UserProfile user) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, color: AppColors.textGrey),
      color: AppColors.surface,
      onSelected: (value) => _handleMenuAction(value, user),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: _MenuRow(LucideIcons.edit, "Edit Info"),
        ),
        PopupMenuItem(
          value: 'block',
          child: _MenuRow(
            user.isBlocked ? LucideIcons.unlock : LucideIcons.lock,
            user.isBlocked ? "Unblock" : "Block User",
            color: user.isBlocked ? Colors.green : Colors.orange,
          ),
        ),
        PopupMenuItem(
          value: 'verify',
          child: _MenuRow(
            user.isVerified ? LucideIcons.userMinus : LucideIcons.userCheck,
            user.isVerified ? "Unverify" : "Verify Account",
            color: Colors.blue,
          ),
        ),
        const PopupMenuItem(
          value: 'reset',
          child: _MenuRow(LucideIcons.key, "Reset Password"),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: _MenuRow(LucideIcons.trash2, "Delete User", color: Colors.red),
        ),
      ],
    );
  }

  void _handleMenuAction(String action, UserProfile user) {
    switch (action) {
      case 'edit':
        _showEditDialog(user);
        break;
      case 'block':
        _dataService.updateUserField(user.id, {'isBlocked': !user.isBlocked});
        break;
      case 'verify':
        _dataService.updateUserField(user.id, {'isVerified': !user.isVerified});
        break;
      case 'reset':
        _confirmResetPassword(user);
        break;
      case 'delete':
        _confirmDelete(user);
        break;
    }
  }

  void _showEditDialog(UserProfile user) {
    final nameController = TextEditingController(text: user.displayName);
    String selectedRole = user.role;
    String selectedSub = user.subscriptionType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            "Edit User Information",
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Display Name",
                    labelStyle: TextStyle(color: AppColors.textGrey),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Role",
                    labelStyle: TextStyle(color: AppColors.textGrey),
                  ),
                  items: ['student', 'instructor', 'admin']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedRole = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedSub,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Subscription",
                    labelStyle: TextStyle(color: AppColors.textGrey),
                  ),
                  items: ['free', 'premium']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedSub = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
              ),
              onPressed: () {
                _dataService.updateUserField(user.id, {
                  'displayName': nameController.text,
                  'role': selectedRole,
                  'subscriptionType': selectedSub,
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetPassword(UserProfile user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Reset Password"),
        content: Text("Send password reset email to ${user.email}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final messenger = ScaffoldMessenger.of(dialogContext);
              try {
                await _dataService.resetUserPassword(user.email);
                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text("Reset email sent!")),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text(
              "Send",
              style: TextStyle(color: AppColors.primaryPink),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Delete User", style: TextStyle(color: Colors.red)),
        content: Text(
          "Deactivate ${user.displayName}? They will be blocked and hidden from management lists.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _dataService.deleteUser(user.id);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(UserProfile user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryPink.withValues(alpha: 0.1),
                  child: const Icon(
                    LucideIcons.user,
                    color: AppColors.primaryPink,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Learning Activities",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              LucideIcons.bookOpen,
              "Courses Enrolled",
              "${user.enrolledCourseIds.length}",
            ),
            _buildDetailRow(
              LucideIcons.checkCircle,
              "Lessons Completed",
              "${user.completedLessonIds.length}",
            ),
            _buildDetailRow(
              LucideIcons.zap,
              "Current Streak",
              "${user.streakCount} days",
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textGrey, size: 16),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textGrey)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _MenuRow(this.icon, this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.white, size: 18),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: color ?? Colors.white)),
      ],
    );
  }
}
