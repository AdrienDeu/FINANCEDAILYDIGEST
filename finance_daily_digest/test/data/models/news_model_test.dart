import 'package:finance_daily_digest/data/models/news_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewsModel', () {
    test('should create a news model', () {
      final news = NewsModel(
        id: 'test-1',
        title: 'Test News',
        description: 'Test Description',
        publishedAt: DateTime.now(),
        cachedAt: DateTime.now(),
      );

      expect(news.id, 'test-1');
      expect(news.title, 'Test News');
      expect(news.description, 'Test Description');
    });

    test('should detect expired cache (1 hour TTL)', () {
      final expiredNews = NewsModel(
        id: 'test-1',
        title: 'Old News',
        publishedAt: DateTime.now(),
        cachedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      expect(expiredNews.isCacheExpired, isTrue);
    });

    test('should detect non-expired cache', () {
      final freshNews = NewsModel(
        id: 'test-1',
        title: 'Fresh News',
        publishedAt: DateTime.now(),
        cachedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      expect(freshNews.isCacheExpired, isFalse);
    });

    test('should detect expired vulgarized content (24 hours TTL)', () {
      final news = NewsModel(
        id: 'test-1',
        title: 'Test',
        publishedAt: DateTime.now(),
        cachedAt: DateTime.now(),
        vulgarizedContent: 'Old content',
        vulgarizedAt: DateTime.now().subtract(const Duration(hours: 25)),
      );

      expect(news.isVulgarizedExpired, isTrue);
    });

    test('should create from JSON', () {
      final json = {
        'id': 'test-1',
        'title': 'Test News',
        'description': 'Test Description',
        'url': 'https://example.com',
        'publishedAt': DateTime.now().toIso8601String(),
      };

      final news = NewsModel.fromJson(json);

      expect(news.id, 'test-1');
      expect(news.title, 'Test News');
      expect(news.description, 'Test Description');
      expect(news.url, 'https://example.com');
    });

    test('should convert to JSON', () {
      final news = NewsModel(
        id: 'test-1',
        title: 'Test News',
        description: 'Test Description',
        publishedAt: DateTime.now(),
        cachedAt: DateTime.now(),
      );

      final json = news.toJson();

      expect(json['id'], 'test-1');
      expect(json['title'], 'Test News');
      expect(json['description'], 'Test Description');
    });

    test('should copy with vulgarized content', () {
      final news = NewsModel(
        id: 'test-1',
        title: 'Test News',
        publishedAt: DateTime.now(),
        cachedAt: DateTime.now(),
      );

      final vulgarized = news.copyWithVulgarized(
        vulgarizedContent: 'Simplified content',
      );

      expect(vulgarized.id, news.id);
      expect(vulgarized.title, news.title);
      expect(vulgarized.vulgarizedContent, 'Simplified content');
      expect(vulgarized.vulgarizedAt, isNotNull);
    });
  });
}
