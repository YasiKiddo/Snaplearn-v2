class ActivityLog {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String type; // 'user', 'course', 'enrollment', 'instructor'

  ActivityLog({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
  });

  factory ActivityLog.fromMap(Map<String, dynamic> data, String id) {
    final timestamp = data['timestamp'];
    return ActivityLog(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      timestamp: timestamp is String
          ? DateTime.tryParse(timestamp) ?? DateTime.now()
          : timestamp as DateTime? ?? DateTime.now(),
      type: data['type'] ?? 'general',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}
