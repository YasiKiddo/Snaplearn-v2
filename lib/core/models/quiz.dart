class Quiz {
  final String id;
  final String courseId;
  final String title;
  final List<Question> questions;
  final int timeLimitMinutes;

  Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    required this.questions,
    this.timeLimitMinutes = 10,
  });

  factory Quiz.fromMap(Map<String, dynamic> data, String id) {
    return Quiz(
      id: id,
      courseId: data['courseId'] ?? '',
      title: data['title'] ?? '',
      questions: (data['questions'] as List? ?? [])
          .whereType<Map>()
          .map((q) => Question.fromMap(Map<String, dynamic>.from(q)))
          .toList(),
      timeLimitMinutes: data['timeLimitMinutes'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeLimitMinutes': timeLimitMinutes,
    };
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }
}
