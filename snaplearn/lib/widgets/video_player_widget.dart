import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';
import '../core/constants/app_colors.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final String? videoPath;
  final bool autoPlay;
  final bool looping;

  const VideoPlayerWidget({
    super.key,
    this.videoUrl,
    this.videoPath,
    this.autoPlay = true,
    this.looping = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final localPath = widget.videoPath?.trim();
      final remoteUrl = widget.videoUrl?.trim();

      if (!kIsWeb &&
          localPath != null &&
          localPath.isNotEmpty &&
          await File(localPath).exists()) {
        _videoPlayerController = VideoPlayerController.file(File(localPath));
      } else if (_isAssetVideoPath(localPath)) {
        _videoPlayerController = VideoPlayerController.asset(localPath!);
      } else if (kIsWeb && _isBrowserPlayablePath(localPath)) {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(localPath!),
        );
      } else if (remoteUrl != null && remoteUrl.isNotEmpty) {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(remoteUrl),
        );
      } else {
        _setError(
          'Video unavailable. Upload it to hosted storage or provide a public URL.',
        );
        return;
      }

      final controller = _videoPlayerController!;
      await controller.initialize();

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        showControls: false,
        aspectRatio: controller.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
      if (mounted) setState(() {});
    } catch (error) {
      _setError('Could not play this video. Check its URL or upload location.');
      debugPrint('Video initialization failed: $error');
    }
  }

  bool _isBrowserPlayablePath(String? path) {
    if (path == null || path.isEmpty) return false;
    final uri = Uri.tryParse(path);
    return uri != null &&
        (uri.scheme == 'blob' ||
            uri.scheme == 'data' ||
            uri.scheme == 'http' ||
            uri.scheme == 'https');
  }

  bool _isAssetVideoPath(String? path) {
    return path != null &&
        (path.startsWith('assets/videos/') ||
            path.startsWith(r'assets\videos\'));
  }

  void _setError(String message) {
    if (mounted) {
      setState(() => _errorMessage = message);
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    } else {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryPink),
      );
    }
  }
}
