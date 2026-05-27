class Course {
  final String id;
  final String title;
  final String description;
  final String instructorId;
  final String instructorName;
  final String thumbnailUrl;
  final String? thumbnailPath; // e.g. assets/photos/course_thumbnail.png
  final String category;
  final List<String> lessonIds;
  final int enrolledCount;
  final double rating;
  final String status;
  final bool isFeatured;
  final double price;
  final List<String> learningObjectives;
  final List<String> requirements;
  final bool isFree;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    required this.thumbnailUrl,
    this.thumbnailPath,
    required this.category,
    this.lessonIds = const [],
    this.enrolledCount = 0,
    this.rating = 0.0,
    this.status = 'published',
    this.isFeatured = false,
    this.price = 0.0,
    this.learningObjectives = const [],
    this.requirements = const [],
    this.isFree = false,
  });

  factory Course.fromMap(Map<String, dynamic> data, String docId) {
    return Course(
      id: docId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructorId: data['instructorId'] ?? '',
      instructorName: data['instructorName'] ?? 'Unknown Instructor',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      thumbnailPath: data['thumbnailPath'],
      category: data['category'] ?? 'General',
      lessonIds: List<String>.from(data['lessonIds'] ?? []),
      enrolledCount: data['enrolledCount'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'published',
      isFeatured: data['isFeatured'] ?? false,
      price: (data['price'] ?? 0.0).toDouble(),
      learningObjectives: List<String>.from(data['learningObjectives'] ?? []),
      requirements: List<String>.from(data['requirements'] ?? []),
      isFree: data['isFree'] ?? (data['price'] == 0.0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'thumbnailUrl': thumbnailUrl,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
      'category': category,
      'lessonIds': lessonIds,
      'enrolledCount': enrolledCount,
      'rating': rating,
      'status': status,
      'isFeatured': isFeatured,
      'price': price,
      'learningObjectives': learningObjectives,
      'requirements': requirements,
      'isFree': isFree,
    };
  }
}
