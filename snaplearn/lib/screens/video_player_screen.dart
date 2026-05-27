import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/models/lesson.dart';
import '../../widgets/video_player_widget.dart';

class VideoPlayerScreen extends StatelessWidget {
  final Lesson lesson;
  const VideoPlayerScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          lesson.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoPlayerWidget(
            videoUrl: lesson.videoUrl,
            videoPath: lesson.videoPath,
          ),
        ),
      ),
    );
  }
}
