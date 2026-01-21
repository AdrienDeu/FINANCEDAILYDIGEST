import '../../../domain/entities/suggestion_entity.dart';
import '../suggestion_model.dart';

/// Extension to convert between SuggestionModel and SuggestionEntity
extension SuggestionModelMapper on SuggestionModel {
  /// Convert SuggestionModel to SuggestionEntity
  SuggestionEntity toEntity() {
    return SuggestionEntity(
      id: id,
      ticker: ticker,
      name: name,
      type: type,
      reasoning: reasoning,
      risk: risk,
      peaEligible: peaEligible,
      createdAt: createdAt,
    );
  }
}

extension SuggestionEntityMapper on SuggestionEntity {
  /// Convert SuggestionEntity to SuggestionModel
  SuggestionModel toModel() {
    return SuggestionModel(
      id: id,
      ticker: ticker,
      name: name,
      type: type,
      reasoning: reasoning,
      risk: risk,
      peaEligible: peaEligible,
      createdAt: createdAt,
      cachedAt: DateTime.now(),
    );
  }
}
