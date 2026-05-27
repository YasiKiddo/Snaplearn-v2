import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, // Fixed width for horizontal scrolling or list
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image with Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Category & Level Badges
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    _imageBadge("Business"),
                    const SizedBox(width: 8),
                    _imageBadge("Intermediate"),
                  ],
                ),
              ),
              // Time Badge
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.clock, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        "8m",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. Course Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Persuasion & Sales Psychology",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "The science of convincing people — from cold emails to...",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Instructor
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 10,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?u=jordan',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Jordan Blake",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stats (Lessons, Learners, Rating)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statItem(LucideIcons.bookOpen, "9 lessons"),
                    _statItem(LucideIcons.users, "14.7k"),
                    _statItem(LucideIcons.star, "4.9", isGold: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String text, {bool isGold = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isGold ? Colors.amber : Colors.white38),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: isGold ? Colors.amber : Colors.white38,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
