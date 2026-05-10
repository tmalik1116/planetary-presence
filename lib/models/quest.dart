enum QuestCategory { nature, culture, food, landmark }

enum QuestStatus { pending, active }

extension QuestCategoryExtension on QuestCategory {
  String get value {
    switch (this) {
      case QuestCategory.nature:
        return 'nature';
      case QuestCategory.culture:
        return 'culture';
      case QuestCategory.food:
        return 'food';
      case QuestCategory.landmark:
        return 'landmark';
    }
  }

  static QuestCategory fromString(String s) {
    switch (s) {
      case 'nature':
        return QuestCategory.nature;
      case 'culture':
        return QuestCategory.culture;
      case 'food':
        return QuestCategory.food;
      case 'landmark':
        return QuestCategory.landmark;
      default:
        throw ArgumentError('Unknown QuestCategory: $s');
    }
  }
}

extension QuestStatusExtension on QuestStatus {
  String get value {
    switch (this) {
      case QuestStatus.pending:
        return 'pending';
      case QuestStatus.active:
        return 'active';
    }
  }

  static QuestStatus fromString(String s) {
    switch (s) {
      case 'pending':
        return QuestStatus.pending;
      case 'active':
        return QuestStatus.active;
      default:
        throw ArgumentError('Unknown QuestStatus: $s');
    }
  }
}

class Quest {
  final String id;
  final String title;
  final String? description;
  final QuestCategory category;
  final String cityId;
  final QuestStatus status;
  final String createdBy;
  final DateTime createdAt;
  final int currentPoints;
  final int completionCount;
  final double avgDifficultyRating;
  final int ratingCount;
  final int netVotes;

  const Quest({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.cityId,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.currentPoints,
    required this.completionCount,
    required this.avgDifficultyRating,
    required this.ratingCount,
    required this.netVotes,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: QuestCategoryExtension.fromString(json['category'] as String),
      cityId: json['city_id'] as String,
      status: QuestStatusExtension.fromString(json['status'] as String),
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      currentPoints: json['current_points'] as int,
      completionCount: json['completion_count'] as int,
      avgDifficultyRating: (json['avg_difficulty_rating'] as num).toDouble(),
      ratingCount: json['rating_count'] as int,
      netVotes: json['net_votes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.value,
      'city_id': cityId,
      'status': status.value,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'current_points': currentPoints,
      'completion_count': completionCount,
      'avg_difficulty_rating': avgDifficultyRating,
      'rating_count': ratingCount,
      'net_votes': netVotes,
    };
  }
}
