class Lesson {
  final String id;
  final String title;
  final String description;
  final String category;
  final String videoUrl;
  final String? videoPath; // e.g. assets/videos/feed_video.mp4
  final String? instructorId;
  final String? courseId; // Added for course grouping
  final int? durationSeconds;
  final int likesCount;
  final int commentsCount;
  final String status;
  final bool isTrending;
  final List<String> hashtags;
  final String? sectionName; // e.g. "Module 1: Getting Started"
  final int orderIndex; // For sorting lessons within a course
  final int reportCount;
  final DateTime? createdAt;

  Lesson({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.videoUrl,
    this.videoPath,
    this.instructorId,
    this.courseId,
    this.durationSeconds,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.status = 'published',
    this.isTrending = false,
    this.hashtags = const [],
    this.sectionName,
    this.orderIndex = 0,
    this.reportCount = 0,
    this.createdAt,
  });

  factory Lesson.fromMap(Map<String, dynamic> data, String id) {
    return Lesson(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      videoPath: data['videoPath'],
      instructorId: data['instructorId'],
      courseId: data['courseId'],
      durationSeconds: data['durationSeconds'],
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      status: data['status'] ?? 'published',
      isTrending: data['isTrending'] ?? false,
      hashtags: List<String>.from(data['hashtags'] ?? []),
      sectionName: data['sectionName'],
      orderIndex: data['orderIndex'] ?? 0,
      reportCount: data['reportCount'] ?? 0,
      createdAt: data['createdAt'] is String
          ? DateTime.tryParse(data['createdAt'])
          : data['createdAt'] as DateTime?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'videoUrl': videoUrl,
      if (videoPath != null) 'videoPath': videoPath,
      if (instructorId != null) 'instructorId': instructorId,
      if (courseId != null) 'courseId': courseId,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'status': status,
      'isTrending': isTrending,
      'hashtags': hashtags,
      'sectionName': sectionName,
      'orderIndex': orderIndex,
      'reportCount': reportCount,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  bool get isFeedVideo => courseId == null || courseId!.trim().isEmpty;
}

// Dummy Data matching your screenshots (now with IDs for local testing if needed)
List<Lesson> sampleLessons = [
  Lesson(
    id: 'lesson_1',
    title: "What is a REST API?",
    category: "CODING",
    videoUrl:
        "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4", // Placeholder
  ),
  Lesson(
    id: 'lesson_2',
    title: "How to start a Business",
    category: "BUSINESS",
    videoUrl:
        "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
  ),
];
