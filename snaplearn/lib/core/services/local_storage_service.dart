import 'package:file_picker/file_picker.dart';

/// Resolves selected media paths for the current local session.
class LocalStorageService {
  static Future<String> uploadVideo(PlatformFile videoFile) async {
    return videoFile.path ?? 'assets/videos/feed_video.mp4';
  }

  static Future<String> uploadPhoto(PlatformFile imageFile) async {
    return imageFile.path ?? 'assets/photos/course_thumbnail.png';
  }
}
