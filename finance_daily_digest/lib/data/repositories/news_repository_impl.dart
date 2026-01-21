import 'dart:developer' as developer;

import '../../domain/entities/daily_digest_entity.dart';
import '../../domain/entities/news_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/cache_service.dart';
import '../datasources/yahoo_finance_datasource.dart';
import '../models/daily_digest_model.dart';
import '../models/mappers/daily_digest_mapper.dart';
import '../models/mappers/news_mapper.dart';
import '../models/mappers/suggestion_mapper.dart';
import '../models/news_model.dart';
import '../models/suggestion_model.dart';

/// Implementation of NewsRepository using Yahoo Finance API and Hive cache
class NewsRepositoryImpl implements NewsRepository {
  final YahooFinanceDataSource yahooDataSource;
  final CacheService cacheService;

  NewsRepositoryImpl({
    required this.yahooDataSource,
    required this.cacheService,
  });

  @override
  Future<DailyDigestEntity> getDailyDigest() async {
    try {
      // 1. Check cache for today's digest
      final cachedDigest = cacheService.getTodayDigest();

      if (cachedDigest != null) {
        developer.log('Using cached digest from ${cachedDigest.date}');

        // Get associated news and suggestions from cache
        final newsEntities = cachedDigest.topNewsIds
            .map((id) => cacheService.getNews(id))
            .whereType<NewsModel>()
            .map((m) => m.toEntity())
            .toList();

        final suggestionEntities = cachedDigest.suggestionIds
            .map((id) => cacheService.getSuggestion(id))
            .where((s) => s != null)
            .cast<SuggestionModel>()
            .map((m) => m.toEntity())
            .toList();

        return cachedDigest.toEntity(
          newsEntities: newsEntities,
          suggestionEntities: suggestionEntities,
        );
      }

      // 2. No cache or expired - fetch from API
      developer.log('Fetching fresh news from Yahoo Finance...');
      final newsJsonList = await yahooDataSource.fetchNews(
        region: 'FR',
        count: 10,
      );

      // 3. Convert to NewsModel and cache
      final newsList = newsJsonList.map((json) {
        return NewsModel.fromJson(json);
      }).toList();

      await cacheService.saveNewsList(newsList);

      // 4. Create digest
      final digest = DailyDigestModel.createToday(
        summary: 'Actualités financières du jour',
        topNewsIds: newsList.take(5).map((n) => n.id).toList(),
        suggestionIds: [], // Will be populated by STORY-011
      );

      await cacheService.saveDigest(digest);

      // 5. Convert to entities and return
      final newsEntities = newsList.take(5).map((m) => m.toEntity()).toList();

      return DailyDigestEntity(
        id: digest.id,
        date: digest.date,
        summary: digest.summary,
        topNews: newsEntities,
        suggestions: [], // Will be populated by STORY-011
        marketSummary: digest.marketSummary,
        createdAt: digest.createdAt,
      );
    } catch (e) {
      developer.log('Error fetching daily digest: $e');

      // Try to return cached digest even if expired (offline mode)
      final cachedDigest = cacheService.getTodayDigest();
      if (cachedDigest != null) {
        final newsEntities = cachedDigest.topNewsIds
            .map((id) => cacheService.getNews(id))
            .whereType<NewsModel>()
            .map((m) => m.toEntity())
            .toList();

        final suggestionEntities = cachedDigest.suggestionIds
            .map((id) => cacheService.getSuggestion(id))
            .where((s) => s != null)
            .cast<SuggestionModel>()
            .map((m) => m.toEntity())
            .toList();

        return cachedDigest.toEntity(
          newsEntities: newsEntities,
          suggestionEntities: suggestionEntities,
        );
      }

      rethrow;
    }
  }

  @override
  Future<List<NewsEntity>> getNews({String? category}) async {
    try {
      // 1. Check cache first
      final cachedNews = category != null
          ? cacheService.getNewsByCategory(category)
          : cacheService.getAllNews();

      if (cachedNews.isNotEmpty) {
        developer.log('Using ${cachedNews.length} cached news items');
        return cachedNews.map((m) => m.toEntity()).toList();
      }

      // 2. Fetch from API
      developer.log('Fetching news from Yahoo Finance...');
      final newsJsonList = await yahooDataSource.fetchNews(
        region: 'FR',
        count: 20,
      );

      // 3. Convert and cache
      final newsList = newsJsonList.map((json) {
        return NewsModel.fromJson(json);
      }).toList();

      await cacheService.saveNewsList(newsList);

      // 4. Filter by category if needed
      var filteredNews = newsList;
      if (category != null) {
        filteredNews = newsList.where((n) => n.category == category).toList();
      }

      return filteredNews.map((m) => m.toEntity()).toList();
    } catch (e) {
      developer.log('Error fetching news: $e');

      // Return cached news even if expired (offline mode)
      final cachedNews = category != null
          ? cacheService.getNewsByCategory(category)
          : cacheService.getAllNews();

      if (cachedNews.isNotEmpty) {
        return cachedNews.map((m) => m.toEntity()).toList();
      }

      rethrow;
    }
  }

  @override
  Future<NewsEntity?> getNewsById(String id) async {
    final newsModel = cacheService.getNews(id);
    return newsModel?.toEntity();
  }

  @override
  Future<List<NewsEntity>> refreshNews() async {
    developer.log('Refreshing news from API...');

    // Clear cache
    await cacheService.clearAllNews();

    // Fetch fresh news
    final newsJsonList = await yahooDataSource.fetchNews(
      region: 'FR',
      count: 20,
    );

    // Convert and cache
    final newsList = newsJsonList.map((json) {
      return NewsModel.fromJson(json);
    }).toList();

    await cacheService.saveNewsList(newsList);

    return newsList.map((m) => m.toEntity()).toList();
  }
}
