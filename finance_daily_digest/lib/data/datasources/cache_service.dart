import 'package:hive/hive.dart';

import '../models/daily_digest_model.dart';
import '../models/entity_stats_model.dart';
import '../models/news_model.dart';
import '../models/suggestion_model.dart';

/// Service for caching data locally with TTL management
class CacheService {
  // Box names
  static const String newsBoxName = 'newsBox';
  static const String suggestionsBoxName = 'suggestionsBox';
  static const String digestBoxName = 'digestBox';
  static const String entityStatsBoxName = 'entityStatsBox';

  // Boxes
  late final Box<NewsModel> _newsBox;
  late final Box<SuggestionModel> _suggestionsBox;
  late final Box<DailyDigestModel> _digestBox;
  late final Box<EntityStatsModel> _entityStatsBox;

  /// Initialize boxes
  Future<void> init() async {
    _newsBox = await Hive.openBox<NewsModel>(newsBoxName);
    _suggestionsBox = await Hive.openBox<SuggestionModel>(suggestionsBoxName);
    _digestBox = await Hive.openBox<DailyDigestModel>(digestBoxName);
    _entityStatsBox = await Hive.openBox<EntityStatsModel>(entityStatsBoxName);

    // Clean expired entries on init
    await cleanExpiredEntries();
  }

  // ==================== NEWS ====================

  /// Save news item
  Future<void> saveNews(NewsModel news) async {
    await _newsBox.put(news.id, news);
  }

  /// Save multiple news items
  Future<void> saveNewsList(List<NewsModel> newsList) async {
    final entries = {for (var news in newsList) news.id: news};
    await _newsBox.putAll(entries);
  }

  /// Get news by ID
  NewsModel? getNews(String id) {
    final news = _newsBox.get(id);
    if (news != null && news.isCacheExpired) {
      // Remove expired news
      _newsBox.delete(id);
      return null;
    }
    return news;
  }

  /// Get all news (non-expired)
  List<NewsModel> getAllNews() {
    return _newsBox.values
        .where((news) => !news.isCacheExpired)
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  /// Get news by category
  List<NewsModel> getNewsByCategory(String category) {
    return _newsBox.values
        .where((news) => !news.isCacheExpired && news.category == category)
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  /// Delete news
  Future<void> deleteNews(String id) async {
    await _newsBox.delete(id);
  }

  /// Clear all news
  Future<void> clearAllNews() async {
    await _newsBox.clear();
  }

  // ==================== SUGGESTIONS ====================

  /// Save suggestion
  Future<void> saveSuggestion(SuggestionModel suggestion) async {
    await _suggestionsBox.put(suggestion.id, suggestion);
  }

  /// Save multiple suggestions
  Future<void> saveSuggestionsList(List<SuggestionModel> suggestions) async {
    final entries = {for (var s in suggestions) s.id: s};
    await _suggestionsBox.putAll(entries);
  }

  /// Get suggestion by ID
  SuggestionModel? getSuggestion(String id) {
    final suggestion = _suggestionsBox.get(id);
    if (suggestion != null && suggestion.isCacheExpired) {
      // Remove expired suggestion
      _suggestionsBox.delete(id);
      return null;
    }
    return suggestion;
  }

  /// Get all suggestions (non-expired)
  List<SuggestionModel> getAllSuggestions() {
    return _suggestionsBox.values
        .where((s) => !s.isCacheExpired)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get suggestions for today
  List<SuggestionModel> getTodaySuggestions() {
    final today = DateTime.now();
    return _suggestionsBox.values.where((s) {
      return !s.isCacheExpired &&
          s.createdAt.year == today.year &&
          s.createdAt.month == today.month &&
          s.createdAt.day == today.day;
    }).toList();
  }

  /// Delete suggestion
  Future<void> deleteSuggestion(String id) async {
    await _suggestionsBox.delete(id);
  }

  /// Clear all suggestions
  Future<void> clearAllSuggestions() async {
    await _suggestionsBox.clear();
  }

  // ==================== DAILY DIGEST ====================

  /// Save daily digest
  Future<void> saveDigest(DailyDigestModel digest) async {
    await _digestBox.put(digest.id, digest);
  }

  /// Get digest by ID
  DailyDigestModel? getDigest(String id) {
    final digest = _digestBox.get(id);
    if (digest != null && digest.isCacheExpired) {
      // Remove expired digest
      _digestBox.delete(id);
      return null;
    }
    return digest;
  }

  /// Get today's digest
  DailyDigestModel? getTodayDigest() {
    final today = DateTime.now();
    final todayKey = 'digest_${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final digest = _digestBox.get(todayKey);
    if (digest != null && digest.isCacheExpired) {
      _digestBox.delete(todayKey);
      return null;
    }
    return digest;
  }

  /// Get all digests (non-expired)
  List<DailyDigestModel> getAllDigests() {
    return _digestBox.values
        .where((d) => !d.isCacheExpired)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Delete digest
  Future<void> deleteDigest(String id) async {
    await _digestBox.delete(id);
  }

  /// Clear all digests
  Future<void> clearAllDigests() async {
    await _digestBox.clear();
  }

  // ==================== ENTITY STATS ====================

  /// Save entity stats
  Future<void> saveEntityStats(EntityStatsModel stats) async {
    await _entityStatsBox.put(stats.cacheKey, stats);
  }

  /// Save multiple entity stats
  Future<void> saveEntityStatsList(List<EntityStatsModel> statsList) async {
    final entries = {for (var s in statsList) s.cacheKey: s};
    await _entityStatsBox.putAll(entries);
  }

  /// Get entity stats by cache key
  EntityStatsModel? getEntityStats(String cacheKey) {
    final stats = _entityStatsBox.get(cacheKey);
    if (stats != null && stats.isCacheExpired) {
      _entityStatsBox.delete(cacheKey);
      return null;
    }
    return stats;
  }

  /// Get entity stats for a symbol within a date range
  List<EntityStatsModel> getEntityStatsForSymbol(
    String symbol,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _entityStatsBox.values.where((stats) {
      if (stats.isCacheExpired) return false;
      if (stats.symbol != symbol) return false;
      return stats.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          stats.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get all cached entity stats for symbols (non-expired)
  List<EntityStatsModel> getAllEntityStatsForSymbols(
    List<String> symbols,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _entityStatsBox.values.where((stats) {
      if (stats.isCacheExpired) return false;
      if (!symbols.contains(stats.symbol)) return false;
      return stats.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          stats.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Check if we have complete cached stats for a query
  bool hasCompleteEntityStats(
    List<String> symbols,
    DateTime startDate,
    DateTime endDate,
  ) {
    for (final symbol in symbols) {
      final stats = getEntityStatsForSymbol(symbol, startDate, endDate);
      if (stats.isEmpty) return false;
    }
    return true;
  }

  /// Delete entity stats
  Future<void> deleteEntityStats(String cacheKey) async {
    await _entityStatsBox.delete(cacheKey);
  }

  /// Clear all entity stats
  Future<void> clearAllEntityStats() async {
    await _entityStatsBox.clear();
  }

  // ==================== MAINTENANCE ====================

  /// Clean expired entries from all boxes
  Future<void> cleanExpiredEntries() async {
    // Clean expired news
    final expiredNews = _newsBox.values
        .where((news) => news.isCacheExpired)
        .map((news) => news.id)
        .toList();
    for (final id in expiredNews) {
      await _newsBox.delete(id);
    }

    // Clean expired suggestions
    final expiredSuggestions = _suggestionsBox.values
        .where((s) => s.isCacheExpired)
        .map((s) => s.id)
        .toList();
    for (final id in expiredSuggestions) {
      await _suggestionsBox.delete(id);
    }

    // Clean expired digests
    final expiredDigests = _digestBox.values
        .where((d) => d.isCacheExpired)
        .map((d) => d.id)
        .toList();
    for (final id in expiredDigests) {
      await _digestBox.delete(id);
    }

    // Clean expired entity stats
    final expiredStats = _entityStatsBox.values
        .where((s) => s.isCacheExpired)
        .map((s) => s.cacheKey)
        .toList();
    for (final key in expiredStats) {
      await _entityStatsBox.delete(key);
    }
  }

  /// Clear all cached data
  Future<void> clearAll() async {
    await _newsBox.clear();
    await _suggestionsBox.clear();
    await _digestBox.clear();
    await _entityStatsBox.clear();
  }

  /// Get cache statistics
  Map<String, int> getCacheStats() {
    return {
      'newsCount': _newsBox.length,
      'suggestionsCount': _suggestionsBox.length,
      'digestsCount': _digestBox.length,
      'entityStatsCount': _entityStatsBox.length,
      'totalEntries': _newsBox.length +
          _suggestionsBox.length +
          _digestBox.length +
          _entityStatsBox.length,
    };
  }

  /// Close all boxes
  Future<void> close() async {
    await _newsBox.close();
    await _suggestionsBox.close();
    await _digestBox.close();
    await _entityStatsBox.close();
  }
}
