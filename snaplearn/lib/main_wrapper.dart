import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/library_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';

/// A wrapper widget that acts as the main shell for the application after login.
/// It contains the BottomNavigationBar and handles switching between main screens.
class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  // The list of top-level screens accessible via the bottom navigation bar.
  // The index corresponds to the selectedIndex in AppProvider.
  final List<Widget> _screens = const [
    HomeScreen(), // Index 0: Main landing page with featured content
    FeedScreen(), // Index 1: TikTok-style scrolling video feed
    CoursesScreen(), // Index 2: Browse available courses
    LibraryScreen(), // Index 3: User's saved/enrolled content
    SearchScreen(), // Index 4: Discover new content/users
    ProfileScreen(), // Index 5: User settings and personal info
  ];

  @override
  Widget build(BuildContext context) {
    // Access the global AppProvider to read the current selected navigation index
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      // Render the currently selected screen from the _screens list
      body: _screens[appProvider.selectedIndex],

      // Custom implementation of a Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 85, // Fixed height for consistent layout
        padding: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: Colors.black, // Match the global dark theme
          border: Border(
            top: BorderSide(
              color: Colors.white10,
              width: 0.5,
            ), // Add a subtle separator line at the top
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceEvenly, // Spreads icons evenly across the width
          children: [
            _navItem(context, LucideIcons.home, "Home", 0),
            _navItem(context, LucideIcons.zap, "Feed", 1),
            _navItem(context, LucideIcons.bookOpen, "Courses", 2),
            _navItem(context, LucideIcons.bookmark, "Library", 3),
            _navItem(context, LucideIcons.search, "Search", 4),
            _navItem(context, LucideIcons.user, "Profile", 5),
          ],
        ),
      ),
    );
  }

  /// Helper method to create individual navigation items (icons + labels)
  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    // Get a non-listening reference to the provider for the tap callback
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    // Selectively listen to only the selectedIndex to avoid unnecessary rebuilds of this item
    final isSelected = context.select(
      (AppProvider p) => p.selectedIndex == index,
    );

    return GestureDetector(
      // Update the global state when this tab is tapped
      onTap: () => appProvider.setSelectedIndex(index),
      // Ensure the entire area (including empty space) is clickable
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display the icon, changing color if it's the currently active tab
            Icon(
              icon,
              color: isSelected ? AppColors.primaryPink : Colors.white54,
              size: 24,
            ),
            const SizedBox(height: 6),
            // Display the label text underneath the icon
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryPink : Colors.white54,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            // Display a small indicator dot below the label if active
            if (isSelected)
              Container(
                height: 2,
                width: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
