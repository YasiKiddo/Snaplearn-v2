import 'dart:async';

import '../models/activity_log.dart';
import '../models/app_feature.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import '../models/quiz.dart';
import '../models/user_profile.dart';

class ReportedComment {
  final String id;
  final String text;
  final String userName;
  final String? userId;
  final int reportCount;

  const ReportedComment({
    required this.id,
    required this.text,
    required this.userName,
    this.userId,
    required this.reportCount,
  });

  ReportedComment copyWith({int? reportCount}) {
    return ReportedComment(
      id: id,
      text: text,
      userName: userName,
      userId: userId,
      reportCount: reportCount ?? this.reportCount,
    );
  }
}

/// Application data repository used while the Node API is expanded beyond auth.
///
/// Content changes persist for the current app session and can later be mapped
/// onto REST endpoints without changing UI consumers.
class DataService {
  DataService._() {
    _lessons.addAll(sampleLessons);
    _courses.addAll([
      Course(
        id: 'course_1',
        title: 'Mastering Flutter & Dart from Zero to Hero',
        description: 'Learn everything about Flutter and Dart.',
        instructorId: 'inst_1',
        instructorName: 'Sarah Williams',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1516116216624-53e697fedbea?q=80&w=400&auto=format&fit=crop',
        category: 'Programming',
        lessonIds: const ['lesson_1'],
        enrolledCount: 2400,
        rating: 4.8,
        isFeatured: true,
        isFree: true,
      ),
      Course(
        id: 'course_2',
        title: 'Business Negotiation Tactics',
        description: 'Close deals effectively.',
        instructorId: 'inst_2',
        instructorName: 'Mike T.',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1556761175-5973dc0f32b7?q=80&w=400&auto=format&fit=crop',
        category: 'Business',
        lessonIds: const ['lesson_2'],
        enrolledCount: 1500,
        rating: 4.5,
        price: 89.99,
      ),
    ]);
    _features.add(
      AppFeature(
        id: 'feature_1',
        title: 'Learn Anywhere',
        subtitle: 'Short lessons built for your schedule',
        colorHex: 'FF1E1B4B',
        iconName: 'star',
        createdAt: DateTime.now(),
      ),
    );
  }

  static final DataService _instance = DataService._();

  factory DataService() => _instance;

  final List<UserProfile> _users = [];
  final List<Course> _courses = [];
  final List<Lesson> _lessons = [];
  final List<Quiz> _quizzes = [];
  final List<AppFeature> _features = [];
  final List<ActivityLog> _activities = [];
  final List<ReportedComment> _comments = [];

  final _usersController = StreamController<List<UserProfile>>.broadcast();
  final _coursesController = StreamController<List<Course>>.broadcast();
  final _lessonsController = StreamController<List<Lesson>>.broadcast();
  final _featuresController = StreamController<List<AppFeature>>.broadcast();
  final _activitiesController = StreamController<List<ActivityLog>>.broadcast();
  final _commentsController =
      StreamController<List<ReportedComment>>.broadcast();

  int _idCounter = 0;

  String _newId(String prefix) => '${prefix}_${++_idCounter}';

  Stream<List<T>> _withInitial<T>(
    List<T> Function() current,
    Stream<List<T>> updates,
  ) async* {
    yield List<T>.unmodifiable(current());
    yield* updates;
  }

  void _emitUsers() => _usersController.add(List.unmodifiable(_users));
  void _emitCourses() => _coursesController.add(List.unmodifiable(_courses));
  void _emitLessons() => _lessonsController.add(List.unmodifiable(_lessons));
  void _emitFeatures() => _featuresController.add(List.unmodifiable(_features));
  void _emitActivities() =>
      _activitiesController.add(List.unmodifiable(_activities));
  void _emitComments() => _commentsController.add(List.unmodifiable(_comments));

  Future<void> logActivity({
    required String title,
    required String subtitle,
    required String type,
  }) async {
    _activities.insert(
      0,
      ActivityLog(
        id: _newId('activity'),
        title: title,
        subtitle: subtitle,
        timestamp: DateTime.now(),
        type: type,
      ),
    );
    _emitActivities();
  }

  Stream<List<ActivityLog>> streamRecentActivities({int limit = 5}) {
    List<ActivityLog> current() => _activities.take(limit).toList();
    return _withInitial(
      current,
      _activitiesController.stream.map((items) => items.take(limit).toList()),
    );
  }

  Stream<List<UserProfile>> streamUsers() {
    List<UserProfile> current() =>
        _users.where((user) => !user.isDeleted).toList();
    return _withInitial(
      current,
      _usersController.stream.map(
        (items) => items.where((user) => !user.isDeleted).toList(),
      ),
    );
  }

  Stream<List<UserProfile>> streamStudents() {
    List<UserProfile> current() => _users
        .where((user) => user.role == 'student' && !user.isDeleted)
        .toList();
    return _withInitial(
      current,
      _usersController.stream.map(
        (items) => items
            .where((user) => user.role == 'student' && !user.isDeleted)
            .toList(),
      ),
    );
  }

  void cacheUserProfile(UserProfile profile) {
    final index = _users.indexWhere((user) => user.id == profile.id);
    if (index == -1) {
      _users.add(profile);
    } else {
      _users[index] = profile;
    }
    _emitUsers();
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    for (final user in _users) {
      if (user.id == uid) return user;
    }
    return null;
  }

  Future<void> createUserProfile(UserProfile user) async =>
      cacheUserProfile(user);

  Future<void> updateUserProfile(UserProfile user) async =>
      cacheUserProfile(user);

  Future<void> updateUserField(String uid, Map<String, dynamic> data) async {
    final user = await getUserProfile(uid);
    if (user == null) return;
    cacheUserProfile(
      UserProfile.fromMap({...user.toMap(), ...data, 'id': uid}),
    );
  }

  Future<void> deleteUser(String uid) {
    return updateUserField(uid, {
      'isBlocked': true,
      'isDeleted': true,
      'role': 'student',
    });
  }

  Future<void> resetUserPassword(String email) async {
    throw UnsupportedError(
      'Password reset needs a Node API endpoint before it can be enabled.',
    );
  }

  Stream<List<UserProfile>> streamInstructors({bool pendingOnly = false}) {
    List<UserProfile> current() => _users.where((user) {
      if (user.isDeleted) return false;
      return pendingOnly
          ? user.instructorApplicationStatus == 'pending'
          : user.role == 'instructor';
    }).toList();
    return _withInitial(current, _usersController.stream.map((_) => current()));
  }

  Future<void> updateInstructorApplication(String uid, String status) async {
    final data = <String, dynamic>{'instructorApplicationStatus': status};
    if (status == 'approved') data['role'] = 'instructor';
    await updateUserField(uid, data);
    if (status == 'approved') {
      await logActivity(
        title: 'Instructor Approved',
        subtitle: 'A new instructor has been verified',
        type: 'instructor',
      );
    }
  }

  Future<void> submitInstructorApplication(
    String uid,
    Map<String, dynamic> applicationData,
  ) async {
    await updateUserField(uid, {
      'instructorApplicationStatus': 'pending',
      ...applicationData,
    });
  }

  Future<List<Lesson>> getLessons() async => List.unmodifiable(_lessons);

  Stream<List<Lesson>> streamLessons() =>
      _withInitial(() => _lessons, _lessonsController.stream);

  Stream<List<Lesson>> streamLessonsByStatus(String status) {
    List<Lesson> current() =>
        _lessons.where((lesson) => lesson.status == status).toList();
    return _withInitial(
      current,
      _lessonsController.stream.map((_) => current()),
    );
  }

  Stream<List<Lesson>> streamLessonsByCourseId(String courseId) {
    List<Lesson> current() =>
        _lessons.where((lesson) => lesson.courseId == courseId).toList();
    return _withInitial(
      current,
      _lessonsController.stream.map((_) => current()),
    );
  }

  Stream<List<Lesson>> streamReportedLessons() {
    List<Lesson> current() {
      final reports = _lessons
          .where((lesson) => lesson.reportCount > 0)
          .toList();
      reports.sort((a, b) => b.reportCount.compareTo(a.reportCount));
      return reports;
    }

    return _withInitial(
      current,
      _lessonsController.stream.map((_) => current()),
    );
  }

  Future<void> addLesson(Lesson lesson) async {
    final id = lesson.id.isEmpty ? _newId('lesson') : lesson.id;
    _lessons.add(Lesson.fromMap(lesson.toMap(), id));
    _emitLessons();
    await logActivity(
      title: 'New Video Uploaded',
      subtitle: '${lesson.title} is now available',
      type: 'lesson',
    );
  }

  Future<void> updateLesson(Lesson lesson) async {
    final index = _lessons.indexWhere((item) => item.id == lesson.id);
    if (index != -1) {
      _lessons[index] = lesson;
      _emitLessons();
    }
  }

  Future<void> updateLessonField(
    String lessonId,
    Map<String, dynamic> data,
  ) async {
    final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
    if (index == -1) return;
    _lessons[index] = Lesson.fromMap({
      ..._lessons[index].toMap(),
      ...data,
    }, lessonId);
    _emitLessons();
  }

  Future<void> deleteLesson(String lessonId) async {
    _lessons.removeWhere((lesson) => lesson.id == lessonId);
    _emitLessons();
  }

  Future<List<Course>> getCourses() async => List.unmodifiable(_courses);

  Stream<List<Course>> streamCourses() =>
      _withInitial(() => _courses, _coursesController.stream);

  Stream<List<Course>> streamCoursesByStatus(String status) {
    List<Course> current() =>
        _courses.where((course) => course.status == status).toList();
    return _withInitial(
      current,
      _coursesController.stream.map((_) => current()),
    );
  }

  Future<void> addCourse(Course course) async {
    final id = course.id.isEmpty ? _newId('course') : course.id;
    _courses.add(Course.fromMap(course.toMap(), id));
    _emitCourses();
    await logActivity(
      title: 'New Course Created',
      subtitle: '${course.title} has been submitted',
      type: 'course',
    );
  }

  Future<void> updateCourse(Course course) async {
    final index = _courses.indexWhere((item) => item.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      _emitCourses();
    }
  }

  Future<void> updateCourseField(
    String courseId,
    Map<String, dynamic> data,
  ) async {
    final index = _courses.indexWhere((course) => course.id == courseId);
    if (index == -1) return;
    _courses[index] = Course.fromMap({
      ..._courses[index].toMap(),
      ...data,
    }, courseId);
    _emitCourses();
  }

  Future<void> deleteCourse(String courseId) async {
    _courses.removeWhere((course) => course.id == courseId);
    _emitCourses();
  }

  Future<Quiz?> getQuizByCourseId(String courseId) async {
    for (final quiz in _quizzes) {
      if (quiz.courseId == courseId) return quiz;
    }
    return null;
  }

  Future<void> addQuiz(Quiz quiz) async {
    final id = quiz.id.isEmpty ? _newId('quiz') : quiz.id;
    _quizzes.removeWhere((item) => item.courseId == quiz.courseId);
    _quizzes.add(Quiz.fromMap(quiz.toMap(), id));
  }

  Stream<List<ReportedComment>> streamReportedComments() {
    List<ReportedComment> current() =>
        _comments.where((comment) => comment.reportCount > 0).toList();
    return _withInitial(
      current,
      _commentsController.stream.map((_) => current()),
    );
  }

  Future<void> deleteComment(String commentId) async {
    _comments.removeWhere((comment) => comment.id == commentId);
    _emitComments();
  }

  Future<void> dismissCommentReport(String commentId) async {
    final index = _comments.indexWhere((comment) => comment.id == commentId);
    if (index == -1) return;
    _comments[index] = _comments[index].copyWith(reportCount: 0);
    _emitComments();
  }

  Future<void> toggleLikeLesson(String userId, Lesson lesson) async {
    final user = await getUserProfile(userId);
    if (user == null) return;
    final liked = List<String>.from(user.likedLessonIds);
    final isLiked = liked.remove(lesson.id);
    if (!isLiked) liked.add(lesson.id);
    await updateUserProfile(user.copyWith(likedLessonIds: liked));
    await updateLessonField(lesson.id, {
      'likesCount': lesson.likesCount + (isLiked ? -1 : 1),
    });
  }

  Future<void> toggleFollowInstructor(
    String userId,
    String instructorId,
  ) async {
    final user = await getUserProfile(userId);
    if (user == null) return;
    final following = List<String>.from(user.followingIds);
    if (!following.remove(instructorId)) following.add(instructorId);
    await updateUserProfile(user.copyWith(followingIds: following));
  }

  Future<void> toggleSaveLesson(String userId, String lessonId) async {
    final user = await getUserProfile(userId);
    if (user == null) return;
    final saved = List<String>.from(user.savedLessonIds);
    if (!saved.remove(lessonId)) saved.add(lessonId);
    await updateUserProfile(user.copyWith(savedLessonIds: saved));
  }

  Future<int> getTotalUsersCount() async =>
      _users.where((user) => !user.isDeleted).length;

  Future<int> getTotalStudentsCount() async =>
      _users.where((user) => user.role == 'student' && !user.isDeleted).length;

  Future<int> getTotalInstructorsCount() async => _users
      .where((user) => user.role == 'instructor' && !user.isDeleted)
      .length;

  Future<int> getTotalEnrollmentsCount() async => _users.fold<int>(
    0,
    (total, user) => total + user.enrolledCourseIds.length,
  );

  Stream<List<UserProfile>> streamStudentsEnrolledInCourse(String courseId) {
    List<UserProfile> current() => _users
        .where((user) => user.enrolledCourseIds.contains(courseId))
        .toList();
    return _withInitial(current, _usersController.stream.map((_) => current()));
  }

  Future<void> removeStudentFromCourse(String userId, String courseId) async {
    final user = await getUserProfile(userId);
    if (user == null) return;
    final enrolled = List<String>.from(user.enrolledCourseIds)
      ..remove(courseId);
    await updateUserProfile(user.copyWith(enrolledCourseIds: enrolled));
  }

  Future<int> getInstructorStudentCount(String instructorId) async {
    final ids = _courses
        .where((course) => course.instructorId == instructorId)
        .map((course) => course.id)
        .toSet();
    return _users
        .where((user) => user.enrolledCourseIds.any(ids.contains))
        .length;
  }

  Future<double> getInstructorEarnings(String instructorId) async {
    final user = await getUserProfile(instructorId);
    return user?.totalEarnings ?? 0.0;
  }

  Stream<List<AppFeature>> streamAppFeatures() =>
      _withInitial(() => _features, _featuresController.stream);

  Future<void> addAppFeature(AppFeature feature) async {
    final id = feature.id.isEmpty ? _newId('feature') : feature.id;
    _features.add(AppFeature.fromMap(feature.toMap(), id));
    _emitFeatures();
    await logActivity(
      title: 'New Banner Added',
      subtitle: '${feature.title} is now on the home screen',
      type: 'feature',
    );
  }

  Future<void> updateAppFeature(AppFeature feature) async {
    final index = _features.indexWhere((item) => item.id == feature.id);
    if (index != -1) {
      _features[index] = feature;
      _emitFeatures();
    }
  }

  Future<void> deleteAppFeature(String featureId) async {
    _features.removeWhere((feature) => feature.id == featureId);
    _emitFeatures();
  }
}
