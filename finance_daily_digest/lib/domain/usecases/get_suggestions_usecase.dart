import '../entities/suggestion_entity.dart';
import '../repositories/ai_repository.dart';

/// Use case for getting investment suggestions from AI
class GetSuggestionsUseCase {
  final AIRepository repository;

  const GetSuggestionsUseCase(this.repository);

  /// Execute the use case to get investment suggestions
  ///
  /// Behavior:
  /// 1. Check cache for today's suggestions (TTL 24h)
  /// 2. If cache valid, return cached suggestions
  /// 3. If cache expired/missing, generate new suggestions via AI
  /// 4. Parse AI response (JSON format)
  /// 5. Cache suggestions
  /// 6. Return 2-3 suggestions adapted for PEA/Europe
  ///
  /// Throws exception if AI call fails and no cache available
  Future<List<SuggestionEntity>> execute() async {
    return await repository.getSuggestions();
  }
}
