import 'news_entity.dart';
import 'suggestion_entity.dart';

/// Domain entity representing a daily financial digest
class DailyDigestEntity {
  final String id;
  final DateTime date;
  final String summary;
  final List<NewsEntity> topNews;
  final List<SuggestionEntity> suggestions;
  final String? marketSummary;
  final DateTime createdAt;

  const DailyDigestEntity({
    required this.id,
    required this.date,
    required this.summary,
    required this.topNews,
    required this.suggestions,
    this.marketSummary,
    required this.createdAt,
  });

  /// Check if this digest is for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  DailyDigestEntity copyWith({
    String? id,
    DateTime? date,
    String? summary,
    List<NewsEntity>? topNews,
    List<SuggestionEntity>? suggestions,
    String? marketSummary,
    DateTime? createdAt,
  }) {
    return DailyDigestEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      summary: summary ?? this.summary,
      topNews: topNews ?? this.topNews,
      suggestions: suggestions ?? this.suggestions,
      marketSummary: marketSummary ?? this.marketSummary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
