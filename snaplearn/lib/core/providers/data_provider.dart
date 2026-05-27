import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snaplearn/core/models/user_profile.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import '../models/app_feature.dart';
import '../services/data_service.dart';

/// `DataProvider` manages application content exposed by the data repository.
/// It uses the `ChangeNotifier` pattern to notify UI components (consumers)
/// whenever the underlying data changes, ensuring the UI stays in sync with the database.
class DataProvider extends ChangeNotifier {
  final DataService _dataService = DataService();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  // Private lists holding the current state of application data
  List<Lesson> _lessons = [];
  List<Course> _courses = [];
  List<UserProfile> _instructors = [];
  List<AppFeature> _appFeatures = [];

  // Loading states for each data category to show progress indicators in the UI
  bool _isLoadingLessons = true;
  bool _isLoadingCourses = true;
  bool _isLoadingInstructors = true;
  bool _isLoadingAppFeatures = true;

  List<Lesson> get lessons => _lessons;
  List<Course> get courses => _courses;
  List<UserProfile> get instructors => _instructors;
  List<AppFeature> get appFeatures => _appFeatures;

  bool get isLoadingLessons => _isLoadingLessons;
  bool get isLoadingCourses => _isLoadingCourses;
  bool get isLoadingInstructors => _isLoadingInstructors;
  bool get isLoadingAppFeatures => _isLoadingAppFeatures;

  // Constructor initializes real-time data streams immediately upon creation
  DataProvider() {
    _initStreams();
  }

  /// Sets up repository listeners.
  /// When repository data changes, these listeners are triggered,
  /// the local state is updated, and `notifyListeners()` tells the UI to rebuild.
  void _initStreams() {
    // Listen to real-time updates for all lessons
    _subscriptions.add(
      _dataService.streamLessons().listen((lessonsData) {
        _lessons = lessonsData;
        _isLoadingLessons = false;
        notifyListeners();
      }),
    );

    // Listen to real-time updates for all courses
    _subscriptions.add(
      _dataService.streamCourses().listen((coursesData) {
        _courses = coursesData;
        _isLoadingCourses = false;
        notifyListeners();
      }),
    );

    // Listen to real-time updates for instructor profiles
    _subscriptions.add(
      _dataService.streamInstructors().listen((instructorsData) {
        _instructors = instructorsData;
        _isLoadingInstructors = false;
        notifyListeners();
      }),
    );

    // Listen to real-time updates for dynamic home screen banners/features
    _subscriptions.add(
      _dataService.streamAppFeatures().listen((featuresData) {
        _appFeatures = featuresData;
        _isLoadingAppFeatures = false;
        notifyListeners();
      }),
    );
  }

  /// Filters the cached list of courses based on a search query.
  /// Checks if the query exists in either the title or the category (case-insensitive).
  List<Course> searchCourses(String query) {
    if (query.isEmpty) return [];
    return _courses
        .where(
          (c) =>
              c.title.toLowerCase().contains(query.toLowerCase()) ||
              c.category.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// Filters the cached list of lessons/videos based on a search query.
  /// Checks if the query exists in either the title or the category (case-insensitive).
  List<Lesson> searchLessons(String query) {
    if (query.isEmpty) return [];
    return _lessons
        .where(
          (l) =>
              l.title.toLowerCase().contains(query.toLowerCase()) ||
              l.category.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
