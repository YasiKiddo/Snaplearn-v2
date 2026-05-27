class AppFeature {
  final String id;
  final String title;
  final String subtitle;
  final String colorHex;
  final String iconName;
  final DateTime createdAt;

  AppFeature({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.colorHex,
    required this.iconName,
    required this.createdAt,
  });

  factory AppFeature.fromMap(Map<String, dynamic> data, String id) {
    return AppFeature(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      colorHex: data['colorHex'] ?? 'FF1E1B4B',
      iconName: data['iconName'] ?? 'star',
      createdAt: data['createdAt'] is String
          ? DateTime.tryParse(data['createdAt']) ?? DateTime.now()
          : data['createdAt'] as DateTime? ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'colorHex': colorHex,
      'iconName': iconName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
