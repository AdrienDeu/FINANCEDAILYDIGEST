import 'dart:developer' as developer;

import '../../domain/entities/daily_digest_entity.dart';
import '../../domain/entities/news_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/cache_service.dart';
import '../datasources/marketaux_datasource.dart';
import '../datasources/yahoo_finance_datasource.dart';
import '../models/daily_digest_model.dart';
import '../models/mappers/daily_digest_mapper.dart';
import '../models/mappers/news_mapper.dart';
import '../models/mappers/suggestion_mapper.dart';
import '../models/news_model.dart';
import '../models/suggestion_model.dart';

/// Implementation of NewsRepository using Marketaux API for news and Yahoo for quotes
class NewsRepositoryImpl implements NewsRepository {
  final MarketauxDataSource marketauxDataSource;
  final YahooQuotesDataSource yahooQuotesDataSource;
  final CacheService cacheService;

  NewsRepositoryImpl({
    required this.marketauxDataSource,
    required this.yahooQuotesDataSource,
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

        // If news are missing from cache, fetch fresh data
        if (newsEntities.isEmpty && cachedDigest.topNewsIds.isNotEmpty) {
          developer.log('Cached news expired, fetching fresh data...');
          // Clear the expired digest and continue to fetch fresh data
          await cacheService.deleteDigest(cachedDigest.id);
        } else {
          return cachedDigest.toEntity(
            newsEntities: newsEntities,
            suggestionEntities: suggestionEntities,
          );
        }
      }

      // 2. No cache or expired - fetch from Marketaux API
      developer.log('Fetching fresh news from Marketaux...');
      final newsJsonList = await marketauxDataSource.fetchGlobalNews(
        limit: 10,
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
        suggestionIds: [],
      );

      await cacheService.saveDigest(digest);

      // 5. Convert to entities and return
      final newsEntities = newsList.take(5).map((m) => m.toEntity()).toList();

      return DailyDigestEntity(
        id: digest.id,
        date: digest.date,
        summary: digest.summary,
        topNews: newsEntities,
        suggestions: [],
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
  Future<List<NewsEntity>> getNews({String? category, NewsRegion? region}) async {
    try {
      // 1. Check cache first (only if no region filter or region is 'all')
      // When a specific region is selected, always fetch fresh data
      if (region == null || region == NewsRegion.all) {
        final cachedNews = category != null
            ? cacheService.getNewsByCategory(category)
            : cacheService.getAllNews();

        if (cachedNews.isNotEmpty) {
          developer.log('Using ${cachedNews.length} cached news items');
          return cachedNews.map((m) => m.toEntity()).toList();
        }
      }

      // 2. Fetch from Marketaux API with region and industry filter
      developer.log('Fetching news from Marketaux (region: ${region?.name ?? 'all'}, industry: $category)...');
      final newsJsonList = await marketauxDataSource.fetchGlobalNews(
        limit: 20,
        region: region ?? NewsRegion.all,
        industry: category,
      );

      // 3. Convert and cache
      final newsList = newsJsonList.map((json) {
        return NewsModel.fromJson(json);
      }).toList();

      // Only cache if fetching all regions
      if (region == null || region == NewsRegion.all) {
        await cacheService.saveNewsList(newsList);
      }

      return newsList.map((m) => m.toEntity()).toList();
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
  Future<List<NewsEntity>> refreshNews({NewsRegion? region}) async {
    developer.log('Refreshing news from Marketaux API (region: ${region?.name ?? 'all'})...');

    // Clear cache only if fetching all regions
    if (region == null || region == NewsRegion.all) {
      await cacheService.clearAllNews();
    }

    // Fetch fresh news from Marketaux with region filter
    final newsJsonList = await marketauxDataSource.fetchGlobalNews(
      limit: 20,
      region: region ?? NewsRegion.all,
    );

    // Convert and cache
    final newsList = newsJsonList.map((json) {
      return NewsModel.fromJson(json);
    }).toList();

    // Only cache if fetching all regions
    if (region == null || region == NewsRegion.all) {
      await cacheService.saveNewsList(newsList);
    }

    return newsList.map((m) => m.toEntity()).toList();
  }

  /// Fetch market summary from Yahoo Finance
  Future<Map<String, dynamic>> getMarketSummary() async {
    return await yahooQuotesDataSource.fetchEuropeanMarketSummary();
  }

  /// Fetch quotes for specific symbols from Yahoo Finance
  Future<List<Map<String, dynamic>>> getQuotes(List<String> symbols) async {
    return await yahooQuotesDataSource.fetchQuotes(symbols);
  }
}
