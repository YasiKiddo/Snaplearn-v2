class Lesson {
  final String title;
  final String category;
  final String videoUrl;

  Lesson({required this.title, required this.category, required this.videoUrl});
}

// Dummy Data matching your screenshots
List<Lesson> sampleLessons = [
  Lesson(
    title: "What is a REST API?",
    category: "CODING",
    videoUrl:
        "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4", // Placeholder
  ),
  Lesson(
    title: "How to start a Business",
    category: "BUSINESS",
    videoUrl:
        "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
  ),
];
