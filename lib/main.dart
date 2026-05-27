import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/data_provider.dart';
import 'main_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'core/constants/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        // AppProvider handles global app state like navigation index, loading state, and user role
        ChangeNotifierProvider(create: (_) => AppProvider()),
        // DataProvider manages fetching and caching application data (courses, features, etc.)
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: const SnapLearnApp(),
    ),
  );
}

/// The root widget of the SnapLearn application.
/// Configures the theme, routing, and initial startup logic.
class SnapLearnApp extends StatelessWidget {
  const SnapLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Hides the "DEBUG" banner in the top right corner
      debugShowCheckedModeBanner: false,

      // Define the global theme for the app (Dark Theme preferred)
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        // Apply Inter font to all text styles globally
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      // Base route of the application
      initialRoute: '/',
      routes: {
        '/': (context) => Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            // 1. Show a loading spinner if the app is still initializing or checking auth state
            if (appProvider.isLoading) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryPink,
                  ),
                ),
              );
            }

            // 2. Check Authentication State
            if (appProvider.isLoggedIn) {
              // 3. Role-Based Routing: Redirect Admins to their specific dashboard
              if (appProvider.isAdmin) {
                return const AdminDashboard();
              }
              // Redirect regular users and instructors to the main app interface
              return const MainWrapper();
            } else {
              // 4. If not logged in, show the Login Screen
              return const LoginScreen();
            }
          },
        ),
      },
    );
  }
}
