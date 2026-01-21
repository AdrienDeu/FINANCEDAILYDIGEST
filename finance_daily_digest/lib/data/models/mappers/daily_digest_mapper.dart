import '../../../domain/entities/daily_digest_entity.dart';
import '../../../domain/entities/news_entity.dart';
import '../../../domain/entities/suggestion_entity.dart';
import '../daily_digest_model.dart';

/// Extension to convert between DailyDigestModel and DailyDigestEntity
extension DailyDigestModelMapper on DailyDigestModel {
  /// Convert DailyDigestModel to DailyDigestEntity
  /// Note: This requires fetching associated news and suggestions from cache
  DailyDigestEntity toEntity({
    required List<NewsEntity> newsEntities,
    required List<SuggestionEntity> suggestionEntities,
  }) {
    return DailyDigestEntity(
      id: id,
      date: date,
      summary: summary,
      topNews: newsEntities,
      suggestions: suggestionEntities,
      marketSummary: marketSummary,
      createdAt: createdAt,
    );
  }
}
