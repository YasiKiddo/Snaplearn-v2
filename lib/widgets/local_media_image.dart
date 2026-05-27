import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String defaultCourseThumbnailUrl =
    'https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=400&auto=format&fit=crop';

ImageProvider courseThumbnailProvider({
  required String? thumbnailPath,
  required String thumbnailUrl,
}) {
  final localPath = thumbnailPath?.trim();
  if (localPath != null && localPath.isNotEmpty) {
    if (_isAssetPhotoPath(localPath)) {
      if (!kIsWeb) {
        final file = File(localPath);
        if (file.existsSync()) {
          return FileImage(file);
        }
      }
      return AssetImage(localPath);
    }

    if (kIsWeb && _isBrowserMediaUrl(localPath)) {
      return NetworkImage(localPath);
    }

    final file = File(localPath);
    if (file.existsSync()) {
      return FileImage(file);
    }
  }

  final remoteUrl = thumbnailUrl.trim();
  if (remoteUrl.isNotEmpty) {
    return NetworkImage(remoteUrl);
  }

  return const NetworkImage(defaultCourseThumbnailUrl);
}

bool _isBrowserMediaUrl(String value) {
  return value.startsWith('blob:') || value.startsWith('data:');
}

bool _isAssetPhotoPath(String value) {
  return value.startsWith('assets/photos/') ||
      value.startsWith(r'assets\photos\');
}

class CourseThumbnail extends StatelessWidget {
  final String? thumbnailPath;
  final String thumbnailUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CourseThumbnail({
    super.key,
    required this.thumbnailPath,
    required this.thumbnailUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image(
      image: courseThumbnailProvider(
        thumbnailPath: thumbnailPath,
        thumbnailUrl: thumbnailUrl,
      ),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: Colors.white10,
        child: const Icon(Icons.image_outlined, color: Colors.white54),
      ),
    );

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
