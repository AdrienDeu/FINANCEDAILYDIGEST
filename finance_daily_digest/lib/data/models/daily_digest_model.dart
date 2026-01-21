import 'package:hive/hive.dart';

part 'daily_digest_model.g.dart';

@HiveType(typeId: 2)
class DailyDigestModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String summary;

  @HiveField(3)
  final List<String> topNewsIds;

  @HiveField(4)
  final List<String> suggestionIds;

  @HiveField(5)
  final String? marketSummary;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime cachedAt;

  DailyDigestModel({
    required this.id,
    required this.date,
    required this.summary,
    required this.topNewsIds,
    required this.suggestionIds,
    this.marketSummary,
    required this.createdAt,
    required this.cachedAt,
  });

  /// Check if the digest cache is expired (24 hours TTL)
  bool get isCacheExpired {
    final now = DateTime.now();
    final difference = now.difference(cachedAt);
    return difference.inHours >= 24;
  }

  /// Check if this digest is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Create from JSON
  factory DailyDigestModel.fromJson(Map<String, dynamic> json) {
    return DailyDigestModel(
      id: json['id'] as String? ?? DateTime.now().toIso8601String(),
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      summary: json['summary'] as String? ?? '',
      topNewsIds: (json['topNewsIds'] as List?)?.cast<String>() ?? [],
      suggestionIds: (json['suggestionIds'] as List?)?.cast<String>() ?? [],
      marketSummary: json['marketSummary'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      cachedAt: DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'summary': summary,
      'topNewsIds': topNewsIds,
      'suggestionIds': suggestionIds,
      'marketSummary': marketSummary,
      'createdAt': createdAt.toIso8601String(),
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  /// Create a new digest for today
  factory DailyDigestModel.createToday({
    required String summary,
    required List<String> topNewsIds,
    required List<String> suggestionIds,
    String? marketSummary,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final id = 'digest_${today.toIso8601String().split('T')[0]}';

    return DailyDigestModel(
      id: id,
      date: today,
      summary: summary,
      topNewsIds: topNewsIds,
      suggestionIds: suggestionIds,
      marketSummary: marketSummary,
      createdAt: now,
      cachedAt: now,
    );
  }
}
