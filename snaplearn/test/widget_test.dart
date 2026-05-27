import 'package:flutter_test/flutter_test.dart';
import 'package:snaplearn/core/models/lesson.dart';
import 'package:snaplearn/core/models/user_profile.dart';

void main() {
  test(
    'UserProfile copyWith preserves account flags and updates interests',
    () {
      final profile = UserProfile(
        id: 'user_1',
        displayName: 'Learner',
        email: 'learner@example.com',
        isBlocked: true,
        isDeleted: true,
        interests: const ['Programming'],
        likedLessonIds: const ['lesson_1'],
      );

      final updated = profile.copyWith(
        displayName: 'Updated Learner',
        interests: const ['Business', 'Design'],
      );

      expect(updated.displayName, 'Updated Learner');
      expect(updated.email, profile.email);
      expect(updated.isBlocked, isTrue);
      expect(updated.isDeleted, isTrue);
      expect(updated.interests, ['Business', 'Design']);
      expect(updated.likedLessonIds, ['lesson_1']);
    },
  );

  test(
    'Lesson feed classification treats null or empty courseId as feed video',
    () {
      final shortVideo = Lesson(
        id: 'short_1',
        title: 'Admin short',
        category: 'CODING',
        videoUrl: 'https://example.com/video.mp4',
        courseId: null,
      );
      final legacyShortVideo = Lesson(
        id: 'short_2',
        title: 'Legacy short',
        category: 'CODING',
        videoUrl: 'https://example.com/video.mp4',
        courseId: '',
      );
      final courseLesson = Lesson(
        id: 'lesson_1',
        title: 'Course lesson',
        category: 'CODING',
        videoUrl: 'https://example.com/video.mp4',
        courseId: 'course_1',
      );

      expect(shortVideo.isFeedVideo, isTrue);
      expect(legacyShortVideo.isFeedVideo, isTrue);
      expect(courseLesson.isFeedVideo, isFalse);
    },
  );
}
