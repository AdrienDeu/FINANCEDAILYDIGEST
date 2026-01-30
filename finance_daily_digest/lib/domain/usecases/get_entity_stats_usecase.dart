import 'dart:developer' as developer;

import '../../data/datasources/cache_service.dart';
import '../../data/datasources/marketaux_datasource.dart';
import '../entities/entity_stats_entity.dart';

/// Use case for getting entity statistics (time series)
class GetEntityStatsUseCase {
  final MarketauxDataSource _marketauxDataSource;
  final CacheService _cacheService;

  GetEntityStatsUseCase(this._marketauxDataSource, this._cacheService);

  /// Execute the use case to get entity stats
  ///
  /// [symbols] - List of stock symbols to fetch stats for
  /// [period] - Time period for the stats
  /// [forceRefresh] - If true, bypass cache and fetch fresh data
  Future<Map<String, SymbolAggregateStats>> execute({
    required List<String> symbols,
    required StatsPeriod period,
    bool forceRefresh = false,
  }) async {
    final startDate = period.startDate;
    final endDate = period.endDate;

    developer.log(
        'GetEntityStatsUseCase: Fetching stats for ${symbols.join(", ")} from $startDate to $endDate');

    // Check cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedStats =
          _cacheService.getAllEntityStatsForSymbols(symbols, startDate, endDate);

      if (cachedStats.isNotEmpty) {
        developer.log('Found ${cachedStats.length} cached stats entries');

        // Group by symbol and check if we have data for all symbols
        final groupedStats = _groupStatsBySymbol(cachedStats, period);

        // If we have data for all requested symbols, return cached
        if (groupedStats.keys.length == symbols.length) {
          developer.log('Returning cached stats for all symbols');
          return groupedStats;
        }
      }
    }

    // Fetch from API
    try {
      developer.log('Fetching fresh stats from Marketaux API...');

      final response = await _marketauxDataSource.fetchEntityStats(
        symbols: symbols,
        startDate: startDate,
        endDate: endDate,
      );

      final models = response.toModelList();

      if (models.isNotEmpty) {
        // Save to cache
        await _cacheService.saveEntityStatsList(models);
        developer.log('Saved ${models.length} stats entries to cache');

        // Convert to entities and group by symbol
        final entities = models
            .map((m) => EntityStatsEntity(
                  symbol: m.symbol,
                  date: m.date,
                  totalDocuments: m.totalDocuments,
                  sentimentAvg: m.sentimentAvg,
                ))
            .toList();

        return _groupEntitiesBySymbol(entities, symbols, period);
      }

      // If no data from API, return empty stats for each symbol
      return _createEmptyStats(symbols, period);
    } catch (e) {
      developer.log('Error fetching stats: $e');

      // Try to return cached data on error
      final cachedStats =
          _cacheService.getAllEntityStatsForSymbols(symbols, startDate, endDate);

      if (cachedStats.isNotEmpty) {
        developer.log('Returning cached stats after API error');
        return _groupStatsBySymbol(cachedStats, period);
      }

      rethrow;
    }
  }

  /// Refresh stats (bypass cache)
  Future<Map<String, SymbolAggregateStats>> refresh({
    required List<String> symbols,
    required StatsPeriod period,
  }) async {
    return execute(symbols: symbols, period: period, forceRefresh: true);
  }

  /// Group cached stats models by symbol
  Map<String, SymbolAggregateStats> _groupStatsBySymbol(
    List<dynamic> cachedStats,
    StatsPeriod period,
  ) {
    final Map<String, List<EntityStatsEntity>> grouped = {};

    for (final stat in cachedStats) {
      final entity = EntityStatsEntity(
        symbol: stat.symbol,
        date: stat.date,
        totalDocuments: stat.totalDocuments,
        sentimentAvg: stat.sentimentAvg,
      );

      grouped.putIfAbsent(entity.symbol, () => []).add(entity);
    }

    // Sort each list by date and create aggregate stats
    return grouped.map((symbol, stats) {
      stats.sort((a, b) => a.date.compareTo(b.date));
      return MapEntry(
        symbol,
        SymbolAggregateStats(
          symbol: symbol,
          dailyStats: stats,
          period: period,
        ),
      );
    });
  }

  /// Group entities by symbol
  Map<String, SymbolAggregateStats> _groupEntitiesBySymbol(
    List<EntityStatsEntity> entities,
    List<String> symbols,
    StatsPeriod period,
  ) {
    final Map<String, List<EntityStatsEntity>> grouped = {};

    // Initialize with all requested symbols
    for (final symbol in symbols) {
      grouped[symbol] = [];
    }

    // Group entities
    for (final entity in entities) {
      if (grouped.containsKey(entity.symbol)) {
        grouped[entity.symbol]!.add(entity);
      }
    }

    // Sort each list by date and create aggregate stats
    return grouped.map((symbol, stats) {
      stats.sort((a, b) => a.date.compareTo(b.date));
      return MapEntry(
        symbol,
        SymbolAggregateStats(
          symbol: symbol,
          dailyStats: stats,
          period: period,
        ),
      );
    });
  }

  /// Create empty stats for all symbols
  Map<String, SymbolAggregateStats> _createEmptyStats(
    List<String> symbols,
    StatsPeriod period,
  ) {
    return {
      for (final symbol in symbols)
        symbol: SymbolAggregateStats(
          symbol: symbol,
          dailyStats: [],
          period: period,
        ),
    };
  }
}
