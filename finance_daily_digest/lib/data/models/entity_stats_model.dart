import 'package:hive/hive.dart';

part 'entity_stats_model.g.dart';

/// Model for entity statistics from Marketaux time series API
@HiveType(typeId: 4)
class EntityStatsModel extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int totalDocuments;

  @HiveField(3)
  final double sentimentAvg;

  @HiveField(4)
  final DateTime cachedAt;

  EntityStatsModel({
    required this.symbol,
    required this.date,
    required this.totalDocuments,
    required this.sentimentAvg,
    required this.cachedAt,
  });

  /// Cache key for storage
  String get cacheKey => '${symbol}_${date.toIso8601String().split('T')[0]}';

  /// Check if the cache is expired (1 hour TTL)
  bool get isCacheExpired {
    final now = DateTime.now();
    final difference = now.difference(cachedAt);
    return difference.inHours >= 1;
  }

  /// Create from JSON (from API response)
  factory EntityStatsModel.fromJson(
    Map<String, dynamic> json,
    String symbol,
    DateTime date,
  ) {
    return EntityStatsModel(
      symbol: symbol,
      date: date,
      totalDocuments: (json['total_documents'] as num?)?.toInt() ?? 0,
      sentimentAvg: (json['sentiment_avg'] as num?)?.toDouble() ?? 0.0,
      cachedAt: DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'date': date.toIso8601String(),
      'total_documents': totalDocuments,
      'sentiment_avg': sentimentAvg,
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  /// Get sentiment color based on value
  /// Green: > 0.2, Yellow: -0.2 to 0.2, Red: < -0.2
  String get sentimentCategory {
    if (sentimentAvg > 0.2) return 'positive';
    if (sentimentAvg < -0.2) return 'negative';
    return 'neutral';
  }

  @override
  String toString() {
    return 'EntityStatsModel(symbol: $symbol, date: $date, totalDocuments: $totalDocuments, sentimentAvg: $sentimentAvg)';
  }
}

/// Response wrapper for entity stats API
class EntityStatsResponse {
  final int found;
  final int returned;
  final int limit;
  final List<EntityStatsDayData> data;

  EntityStatsResponse({
    required this.found,
    required this.returned,
    required this.limit,
    required this.data,
  });

  factory EntityStatsResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    final dataList = json['data'] as List<dynamic>? ?? [];

    return EntityStatsResponse(
      found: (meta['found'] as num?)?.toInt() ?? 0,
      returned: (meta['returned'] as num?)?.toInt() ?? 0,
      limit: (meta['limit'] as num?)?.toInt() ?? 100,
      data: dataList
          .map((item) =>
              EntityStatsDayData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert to flat list of EntityStatsModel
  List<EntityStatsModel> toModelList() {
    final List<EntityStatsModel> models = [];
    for (final dayData in data) {
      for (final symbolData in dayData.symbolStats) {
        models.add(EntityStatsModel(
          symbol: symbolData.symbol,
          date: dayData.date,
          totalDocuments: symbolData.totalDocuments,
          sentimentAvg: symbolData.sentimentAvg,
          cachedAt: DateTime.now(),
        ));
      }
    }
    return models;
  }
}

/// Data for a single day
class EntityStatsDayData {
  final DateTime date;
  final List<SymbolStats> symbolStats;

  EntityStatsDayData({
    required this.date,
    required this.symbolStats,
  });

  factory EntityStatsDayData.fromJson(Map<String, dynamic> json) {
    DateTime date;
    try {
      date = DateTime.parse(json['date'] as String);
    } catch (_) {
      date = DateTime.now();
    }

    final dataList = json['data'] as List<dynamic>? ?? [];
    return EntityStatsDayData(
      date: date,
      symbolStats: dataList
          .map((item) => SymbolStats.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Statistics for a single symbol
class SymbolStats {
  final String symbol;
  final int totalDocuments;
  final double sentimentAvg;

  SymbolStats({
    required this.symbol,
    required this.totalDocuments,
    required this.sentimentAvg,
  });

  factory SymbolStats.fromJson(Map<String, dynamic> json) {
    return SymbolStats(
      symbol: json['key'] as String? ?? '',
      totalDocuments: (json['total_documents'] as num?)?.toInt() ?? 0,
      sentimentAvg: (json['sentiment_avg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
