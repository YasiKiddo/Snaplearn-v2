import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/constants/app_colors.dart';
import '../main_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progressValue = 0.50; // Tracks the loading bar progress

  @override
  void initState() {
    super.initState();
    _startLoading(); // Start the progress bar animation
  }

  // Logic to simulate loading and then navigate to the main app
  void _startLoading() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_progressValue >= 1.0) {
          timer.cancel();
          // Navigate to the MainWrapper after loading is done
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainWrapper()),
          );
        } else {
          _progressValue += 0.02; // Increase progress
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Deep dark background
      body: Stack(
        children: [
          // 1. BACKGROUND RADIAL GLOW (The purple light behind the logo)
          Center(
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryPink.withValues(
                      alpha: 0.15,
                    ), // Soft pink glow
                    Colors.transparent, // Fades out to black
                  ],
                ),
              ),
            ),
          ),

          // 2. GEOMETRIC DIAGONAL LINES (Custom Painter for the sharp lines)
          Positioned.fill(child: CustomPaint(painter: DiagonalLinesPainter())),

          // 3. CENTRAL CONTENT (Logo and Text)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // THE LOGO CIRCLE
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A), // Dark circle background
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPink.withValues(alpha: 0.5),
                        blurRadius: 40, // Neon glow effect
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.zap,
                    color: AppColors.primaryPink,
                    size: 80, // Large lightning bolt
                  ),
                ),
                const SizedBox(height: 40),
                // SNAPLEARN TEXT
                const Text(
                  "SNAPLEARN",
                  style: TextStyle(
                    color: AppColors.primaryPink,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2, // Spaced out letters
                  ),
                ),
                const SizedBox(height: 10),
                // BITE-SIZED MASTERY TEXT
                Text(
                  "BITE-SIZED MASTERY",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6, // Wide spacing to match image
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. BOTTOM LOADING SECTION
          Positioned(
            bottom: 80,
            left: 60,
            right: 60,
            child: Column(
              children: [
                // THE PROGRESS BAR
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    backgroundColor: Colors.white10, // Dark grey track
                    color: AppColors.primaryPink, // Pink filled part
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 20),
                // INITIALIZING TEXT
                Text(
                  "INITIALIZING EXPERIENCE",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// CUSTOM PAINTER FOR THE DIAGONAL LINES
class DiagonalLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
          .withValues(alpha: 0.05) // Very subtle lines
      ..strokeWidth = 1.0;

    // Drawing a few specific lines to match the image pattern
    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, 0),
      Offset(size.width * 0.2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.8),
      Offset(size.width, size.height * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
