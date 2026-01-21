import 'dart:convert';
import 'dart:developer' as developer;

import '../../domain/entities/news_entity.dart';
import '../../domain/entities/suggestion_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/cache_service.dart';
import '../datasources/openrouter_datasource.dart';
import '../models/mappers/news_mapper.dart';
import '../models/mappers/suggestion_mapper.dart';

/// Implementation of AIRepository using OpenRouter API
class AIRepositoryImpl implements AIRepository {
  final OpenRouterDataSource openRouterDataSource;
  final CacheService cacheService;

  AIRepositoryImpl({
    required this.openRouterDataSource,
    required this.cacheService,
  });

  @override
  Future<NewsEntity> vulgarizeArticle(NewsEntity news) async {
    try {
      developer.log('Vulgarizing article: ${news.title}');

      // Call OpenRouter AI
      final vulgarizedContent = await openRouterDataSource.vulgarizeArticle(
        articleTitle: news.title,
        articleContent: news.description ?? news.title,
      );

      // Update news entity with vulgarized content
      final updatedNews = news.copyWith(
        vulgarizedContent: vulgarizedContent,
        vulgarizedAt: DateTime.now(),
      );

      // Save to cache
      await cacheService.saveNews(updatedNews.toModel());

      developer.log('Article vulgarized and cached');
      return updatedNews;
    } catch (e) {
      developer.log('Error vulgarizing article: $e');
      rethrow;
    }
  }

  @override
  Future<List<SuggestionEntity>> getSuggestions() async {
    try {
      // 1. Check cache for today's suggestions
      final cachedSuggestions = cacheService.getTodaySuggestions();

      if (cachedSuggestions.isNotEmpty) {
        developer.log('Using ${cachedSuggestions.length} cached suggestions');
        return cachedSuggestions.map((m) => m.toEntity()).toList();
      }

      // 2. Generate new suggestions via AI
      developer.log('Generating new suggestions via AI...');

      // Get recent news for context
      final recentNews = cacheService.getAllNews();
      final newsDigest = recentNews.take(5).map((n) {
        return '- ${n.title}: ${n.description ?? ""}';
      }).join('\n');

      // Call OpenRouter AI
      final aiResponse = await openRouterDataSource.generateInvestmentSuggestions(
        newsDigest: newsDigest.isNotEmpty
            ? newsDigest
            : 'Actualités financières du marché européen',
      );

      // 3. Parse JSON response
      final suggestions = _parseSuggestionsFromAI(aiResponse);

      if (suggestions.isEmpty) {
        throw Exception('No suggestions generated from AI');
      }

      // 4. Convert to models and cache
      final suggestionModels = suggestions.map((entity) {
        return entity.toModel();
      }).toList();

      await cacheService.saveSuggestionsList(suggestionModels);

      developer.log('Generated and cached ${suggestions.length} suggestions');
      return suggestions;
    } catch (e) {
      developer.log('Error getting suggestions: $e');

      // Return cached suggestions even if expired (offline mode)
      final cachedSuggestions = cacheService.getAllSuggestions();
      if (cachedSuggestions.isNotEmpty) {
        developer.log('Returning ${cachedSuggestions.length} expired cached suggestions');
        return cachedSuggestions.map((m) => m.toEntity()).toList();
      }

      rethrow;
    }
  }

  /// Parse AI response to extract suggestions
  List<SuggestionEntity> _parseSuggestionsFromAI(String aiResponse) {
    try {
      // Try to extract JSON from response
      // AI might return markdown code blocks like ```json...```
      String jsonString = aiResponse.trim();

      // Remove markdown code blocks if present
      if (jsonString.contains('```json')) {
        final start = jsonString.indexOf('```json') + 7;
        final end = jsonString.lastIndexOf('```');
        if (end > start) {
          jsonString = jsonString.substring(start, end).trim();
        }
      } else if (jsonString.contains('```')) {
        final start = jsonString.indexOf('```') + 3;
        final end = jsonString.lastIndexOf('```');
        if (end > start) {
          jsonString = jsonString.substring(start, end).trim();
        }
      }

      // Find JSON object in response
      final jsonStart = jsonString.indexOf('{');
      final jsonEnd = jsonString.lastIndexOf('}');

      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        jsonString = jsonString.substring(jsonStart, jsonEnd + 1);
      }

      // Parse JSON
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final suggestionsJson = jsonData['suggestions'] as List?;

      if (suggestionsJson == null || suggestionsJson.isEmpty) {
        return [];
      }

      // Convert to entities
      return suggestionsJson.map((json) {
        return _createSuggestionEntity(json as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      developer.log('Error parsing suggestions JSON: $e');
      developer.log('AI Response was: $aiResponse');

      // Fallback: return empty list
      return [];
    }
  }

  /// Create a SuggestionEntity from JSON
  SuggestionEntity _createSuggestionEntity(Map<String, dynamic> json) {
    final now = DateTime.now();
    final id = 'sug_${now.millisecondsSinceEpoch}_${json['ticker'] ?? 'unknown'}';

    return SuggestionEntity(
      id: id,
      ticker: json['ticker'] as String? ?? 'N/A',
      name: json['name'] as String? ?? 'N/A',
      type: json['type'] as String? ?? 'Action',
      reasoning: json['reasoning'] as String? ?? '',
      risk: json['risk'] as String? ?? 'Moyen',
      peaEligible: json['peaEligible'] as bool? ?? true,
      createdAt: now,
    );
  }
}
