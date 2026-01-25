import '../entities/daily_digest_entity.dart';
import '../entities/news_entity.dart';

/// Repository interface for news and digest operations
abstract class NewsRepository {
  /// Get daily digest for today
  /// Returns cached digest if available and not expired (TTL 24h)
  /// Otherwise fetches from API and caches
  Future<DailyDigestEntity> getDailyDigest();

  /// Get all news from cache or API
  /// [category] - Optional category filter (action, etf, obligation, general)
  /// [region] - Optional region filter (europe, usa, asia, all)
  Future<List<NewsEntity>> getNews({String? category, NewsRegion? region});

  /// Get a specific news article by ID
  Future<NewsEntity?> getNewsById(String id);

  /// Refresh news from API (invalidates cache)
  /// [region] - Optional region filter (europe, usa, asia, all)
  Future<List<NewsEntity>> refreshNews({NewsRegion? region});
}
