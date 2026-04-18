import 'dart:ui'; // Necessary for ImageFilter
import 'package:flutter/material.dart';

class VideoPreviewCard extends StatelessWidget {
  const VideoPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 450,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white10, width: 8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // The Image
              Image.network(
                'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?q=80&w=1000',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
              // The Info Overlay
              Positioned(
                bottom: 20,
                left: 15,
                right: 15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    // Applying the real blur effect here
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // Reduced opacity slightly to make the blur more visible
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              // Note: Ensure these assets exist in your pubspec.yaml
                              Image.asset(
                                'assets/icons/code-xml.png',
                                color: Colors.purpleAccent,
                                width: 14,
                                height: 14,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.code,
                                      size: 14,
                                      color: Colors.purpleAccent,
                                    ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "CODING",
                                style: TextStyle(
                                  color: Colors.purpleAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "What is a REST API?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Image.asset(
                                'assets/icons/timer.png',
                                color: Colors.grey,
                                width: 14,
                                height: 14,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.timer,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "45 sec",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
