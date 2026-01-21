import 'dart:io';

import 'package:finance_daily_digest/data/datasources/cache_service.dart';
import 'package:finance_daily_digest/data/models/daily_digest_model.dart';
import 'package:finance_daily_digest/data/models/news_model.dart';
import 'package:finance_daily_digest/data/models/suggestion_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUpAll(() async {
      // Initialize Hive in memory for tests
      Hive.init(Directory.systemTemp.path);
      Hive.registerAdapter(NewsModelAdapter());
      Hive.registerAdapter(SuggestionModelAdapter());
      Hive.registerAdapter(DailyDigestModelAdapter());
    });

    setUp(() async {
      cacheService = CacheService();
      await cacheService.init();
      await cacheService.clearAll();
    });

    tearDown(() async {
      await cacheService.clearAll();
      await cacheService.close();
    });

    group('News Cache', () {
      test('should save and retrieve news', () async {
        final news = NewsModel(
          id: 'test-1',
          title: 'Test News',
          publishedAt: DateTime.now(),
          cachedAt: DateTime.now(),
        );

        await cacheService.saveNews(news);
        final retrieved = cacheService.getNews('test-1');

        expect(retrieved, isNotNull);
        expect(retrieved?.id, 'test-1');
        expect(retrieved?.title, 'Test News');
      });

      test('should save multiple news items', () async {
        final newsList = [
          NewsModel(
            id: 'test-1',
            title: 'News 1',
            publishedAt: DateTime.now(),
            cachedAt: DateTime.now(),
          ),
          NewsModel(
            id: 'test-2',
            title: 'News 2',
            publishedAt: DateTime.now(),
            cachedAt: DateTime.now(),
          ),
        ];

        await cacheService.saveNewsList(newsList);
        final allNews = cacheService.getAllNews();

        expect(allNews.length, 2);
      });

      test('should not return expired news', () async {
        final expiredNews = NewsModel(
          id: 'test-1',
          title: 'Expired News',
          publishedAt: DateTime.now(),
          cachedAt: DateTime.now().subtract(const Duration(hours: 2)),
        );

        await cacheService.saveNews(expiredNews);
        final retrieved = cacheService.getNews('test-1');

        expect(retrieved, isNull);
      });

      test('should delete news', () async {
        final news = NewsModel(
          id: 'test-1',
          title: 'Test News',
          publishedAt: DateTime.now(),
          cachedAt: DateTime.now(),
        );

        await cacheService.saveNews(news);
        await cacheService.deleteNews('test-1');
        final retrieved = cacheService.getNews('test-1');

        expect(retrieved, isNull);
      });
    });

    group('Suggestions Cache', () {
      test('should save and retrieve suggestion', () async {
        final suggestion = SuggestionModel(
          id: 'test-1',
          ticker: 'AAPL',
          name: 'Apple Inc.',
          type: 'Action',
          reasoning: 'Good fundamentals',
          risk: 'Moyen',
          createdAt: DateTime.now(),
          cachedAt: DateTime.now(),
        );

        await cacheService.saveSuggestion(suggestion);
        final retrieved = cacheService.getSuggestion('test-1');

        expect(retrieved, isNotNull);
        expect(retrieved?.ticker, 'AAPL');
      });

      test('should get today suggestions', () async {
        final today = SuggestionModel(
          id: 'today-1',
          ticker: 'AAPL',
          name: 'Apple',
          type: 'Action',
          reasoning: 'Test',
          risk: 'Moyen',
          createdAt: DateTime.now(),
          cachedAt: DateTime.now(),
        );

        final yesterday = SuggestionModel(
          id: 'yesterday-1',
          ticker: 'GOOGL',
          name: 'Google',
          type: 'Action',
          reasoning: 'Test',
          risk: 'Moyen',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          cachedAt: DateTime.now(),
        );

        await cacheService.saveSuggestion(today);
        await cacheService.saveSuggestion(yesterday);

        final todaySuggestions = cacheService.getTodaySuggestions();

        expect(todaySuggestions.length, 1);
        expect(todaySuggestions.first.id, 'today-1');
      });
    });

    group('Digest Cache', () {
      test('should save and retrieve digest', () async {
        final digest = DailyDigestModel.createToday(
          summary: 'Test Summary',
          topNewsIds: ['news-1', 'news-2'],
          suggestionIds: ['sug-1'],
        );

        await cacheService.saveDigest(digest);
        final retrieved = cacheService.getTodayDigest();

        expect(retrieved, isNotNull);
        expect(retrieved?.summary, 'Test Summary');
        expect(retrieved?.topNewsIds.length, 2);
      });

      test('should get today digest', () async {
        final digest = DailyDigestModel.createToday(
          summary: 'Today Summary',
          topNewsIds: ['news-1'],
          suggestionIds: ['sug-1'],
        );

        await cacheService.saveDigest(digest);
        final todayDigest = cacheService.getTodayDigest();

        expect(todayDigest, isNotNull);
        expect(todayDigest?.isToday, isTrue);
      });
    });

    group('Cache Maintenance', () {
      test('should get cache statistics', () async {
        final news = NewsModel(
          id: 'test-1',
          title: 'Test',
          publishedAt: DateTime.now(),
          cachedAt: DateTime.now(),
        );

        await cacheService.saveNews(news);
        final stats = cacheService.getCacheStats();

        expect(stats['newsCount'], 1);
        expect(stats['totalEntries'], 1);
      });

      test('should clean expired entries', () async {
        final expiredNews = NewsModel(
          id: 'expired',
          title: 'Expired',
          publishedAt: DateTime.now(),
          cachedAt: DateTime.now().subtract(const Duration(hours: 2)),
        );

        final freshNews = NewsModel(
          id: 'fresh',
          title: 'Fresh',
          publishedAt: DateTime.now(),
          cachedAt: DateTime.now(),
        );

        await cacheService.saveNews(expiredNews);
        await cacheService.saveNews(freshNews);

        await cacheService.cleanExpiredEntries();

        final allNews = cacheService.getAllNews();
        expect(allNews.length, 1);
        expect(allNews.first.id, 'fresh');
      });

      test('should clear all cache', () async {
        await cacheService.saveNews(NewsModel(
          id: 'test',
          title: 'Test',
          publishedAt: DateTime.now(),
          cachedAt: DateTime.now(),
        ));

        await cacheService.clearAll();

        final stats = cacheService.getCacheStats();
        expect(stats['totalEntries'], 0);
      });
    });
  });
}
