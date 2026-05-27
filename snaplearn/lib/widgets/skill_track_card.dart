import 'package:flutter/material.dart';

class SkillTrackCard extends StatelessWidget {
  final String title;
  final String lessons;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;

  const SkillTrackCard({
    super.key,
    required this.title,
    required this.lessons,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgColor, bgColor.withValues(alpha: 0.7)],
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 32),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(lessons, style: TextStyle(color: Colors.white54, fontSize: 16)),
        ],
      ),
    );
  }
}
