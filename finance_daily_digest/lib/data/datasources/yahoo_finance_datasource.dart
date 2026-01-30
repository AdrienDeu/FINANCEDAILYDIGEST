import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'exceptions/api_exception.dart';
import 'http/dio_client.dart';

/// DataSource for Yahoo Finance - Market Quotes and Historical Data
///
/// This datasource is used for fetching market summary/quotes and historical chart data.
/// News fetching has been migrated to MarketauxDataSource.
class YahooQuotesDataSource {
  final DioClient _dioClient;
  final DioClient _chartDioClient;

  YahooQuotesDataSource({
    DioClient? dioClient,
    DioClient? chartDioClient,
  })  : _dioClient = dioClient ??
            DioClient(
              baseUrl: 'https://query2.finance.yahoo.com',
            ),
        _chartDioClient = chartDioClient ??
            DioClient(
              baseUrl: 'https://query1.finance.yahoo.com',
            );

  /// Fetch market summary for European markets
  Future<Map<String, dynamic>> fetchEuropeanMarketSummary() async {
    try {
      developer.log('Fetching European market summary from Yahoo Finance...');

      final response = await _dioClient.dio.get(
        '/v6/finance/quote/marketSummary',
        queryParameters: {
          'region': 'FR',
          'lang': 'fr-FR',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final marketSummary =
            data['marketSummaryResponse'] as Map<String, dynamic>?;
        final result = marketSummary?['result'] as List?;

        if (result != null && result.isNotEmpty) {
          developer.log('Market summary fetched successfully');
          return result[0] as Map<String, dynamic>;
        }
      }

      throw const ParseException('Format de réponse invalide');
    } on DioException catch (e) {
      developer.log('Yahoo Finance API error: ${e.message}');

      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ClientException(
        e.message ?? 'Erreur lors de la récupération du résumé de marché',
        e.response?.statusCode,
      );
    } catch (e) {
      developer.log('Error fetching market summary: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ParseException(
        'Erreur de parsing: ${e.toString()}',
        e,
      );
    }
  }

  /// Fetch quotes for specific symbols
  Future<List<Map<String, dynamic>>> fetchQuotes(List<String> symbols) async {
    try {
      developer.log('Fetching quotes for ${symbols.length} symbols...');

      final response = await _dioClient.dio.get(
        '/v6/finance/quote',
        queryParameters: {
          'symbols': symbols.join(','),
          'region': 'FR',
          'lang': 'fr-FR',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final quoteResponse = data['quoteResponse'] as Map<String, dynamic>?;
        final result = quoteResponse?['result'] as List?;

        if (result != null) {
          developer.log('Fetched ${result.length} quotes');
          return result.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } on DioException catch (e) {
      developer.log('Yahoo Finance quotes error: ${e.message}');

      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ClientException(
        e.message ?? 'Erreur lors de la récupération des quotes',
        e.response?.statusCode,
      );
    } catch (e) {
      developer.log('Error fetching quotes: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ParseException(
        'Erreur de parsing: ${e.toString()}',
        e,
      );
    }
  }

  /// Fetch historical chart data for a symbol
  ///
  /// [symbol] - Stock symbol (e.g., AAPL, MSFT)
  /// [range] - Time range: 7d, 1mo, 3mo, 6mo, 1y
  /// [interval] - Data interval: 1d (daily)
  Future<StockChartResponse> fetchChartData({
    required String symbol,
    String range = '1mo',
    String interval = '1d',
  }) async {
    try {
      developer.log('Fetching chart data for $symbol (range: $range)...');

      final response = await _chartDioClient.dio.get(
        '/v8/finance/chart/$symbol',
        queryParameters: {
          'range': range,
          'interval': interval,
          'includePrePost': false,
          'events': 'div,split',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final chart = data['chart'] as Map<String, dynamic>?;
        final result = chart?['result'] as List?;

        if (result != null && result.isNotEmpty) {
          final chartData = result[0] as Map<String, dynamic>;
          developer.log('Chart data fetched successfully for $symbol');
          return StockChartResponse.fromJson(chartData, symbol);
        }

        // Check for error
        final error = chart?['error'] as Map<String, dynamic>?;
        if (error != null) {
          throw ClientException(
            error['description'] as String? ?? 'Erreur Yahoo Finance',
            null,
          );
        }
      }

      return StockChartResponse.empty(symbol);
    } on DioException catch (e) {
      developer.log('Yahoo Finance chart error: ${e.message}');

      if (e.response?.statusCode == 404) {
        throw ClientException(
          'Symbole "$symbol" non trouvé',
          404,
        );
      }

      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw NetworkException(
        'Erreur réseau: ${e.message}',
      );
    } catch (e) {
      developer.log('Error fetching chart data: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ParseException(
        'Erreur de parsing: ${e.toString()}',
        e,
      );
    }
  }

  /// Fetch chart data for multiple symbols
  Future<Map<String, StockChartResponse>> fetchMultipleCharts({
    required List<String> symbols,
    String range = '1mo',
    String interval = '1d',
  }) async {
    final results = <String, StockChartResponse>{};

    for (final symbol in symbols) {
      try {
        results[symbol] = await fetchChartData(
          symbol: symbol,
          range: range,
          interval: interval,
        );
      } catch (e) {
        developer.log('Failed to fetch chart for $symbol: $e');
        results[symbol] = StockChartResponse.empty(symbol);
      }
    }

    return results;
  }
}

/// Response wrapper for Yahoo Finance chart data
class StockChartResponse {
  final String symbol;
  final String currency;
  final String exchangeName;
  final List<StockDataPoint> dataPoints;

  StockChartResponse({
    required this.symbol,
    required this.currency,
    required this.exchangeName,
    required this.dataPoints,
  });

  factory StockChartResponse.empty(String symbol) {
    return StockChartResponse(
      symbol: symbol,
      currency: 'USD',
      exchangeName: '',
      dataPoints: [],
    );
  }

  factory StockChartResponse.fromJson(Map<String, dynamic> json, String symbol) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    final timestamps = json['timestamp'] as List<dynamic>? ?? [];
    final indicators = json['indicators'] as Map<String, dynamic>? ?? {};
    final quote = (indicators['quote'] as List<dynamic>?)?.firstOrNull
        as Map<String, dynamic>?;
    final adjClose = (indicators['adjclose'] as List<dynamic>?)?.firstOrNull
        as Map<String, dynamic>?;

    final dataPoints = <StockDataPoint>[];

    if (quote != null && timestamps.isNotEmpty) {
      final opens = quote['open'] as List<dynamic>? ?? [];
      final highs = quote['high'] as List<dynamic>? ?? [];
      final lows = quote['low'] as List<dynamic>? ?? [];
      final closes = quote['close'] as List<dynamic>? ?? [];
      final volumes = quote['volume'] as List<dynamic>? ?? [];
      final adjCloses = adjClose?['adjclose'] as List<dynamic>? ?? closes;

      for (int i = 0; i < timestamps.length; i++) {
        final timestamp = timestamps[i] as int?;
        if (timestamp == null) continue;

        final open = (opens.length > i ? opens[i] : null) as num?;
        final high = (highs.length > i ? highs[i] : null) as num?;
        final low = (lows.length > i ? lows[i] : null) as num?;
        final close = (closes.length > i ? closes[i] : null) as num?;
        final volume = (volumes.length > i ? volumes[i] : null) as num?;
        final adjCloseVal = (adjCloses.length > i ? adjCloses[i] : close) as num?;

        // Skip if all values are null (market closed)
        if (open == null && high == null && low == null && close == null) {
          continue;
        }

        dataPoints.add(StockDataPoint(
          date: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
          open: open?.toDouble() ?? 0,
          high: high?.toDouble() ?? 0,
          low: low?.toDouble() ?? 0,
          close: close?.toDouble() ?? 0,
          adjustedClose: adjCloseVal?.toDouble() ?? close?.toDouble() ?? 0,
          volume: volume?.toInt() ?? 0,
        ));
      }
    }

    return StockChartResponse(
      symbol: symbol,
      currency: meta['currency'] as String? ?? 'USD',
      exchangeName: meta['exchangeName'] as String? ?? '',
      dataPoints: dataPoints,
    );
  }

  bool get isEmpty => dataPoints.isEmpty;
  bool get isNotEmpty => dataPoints.isNotEmpty;

  /// Get price change over the period
  double get priceChange {
    if (dataPoints.length < 2) return 0;
    return dataPoints.last.close - dataPoints.first.close;
  }

  /// Get price change percentage
  double get priceChangePercent {
    if (dataPoints.length < 2 || dataPoints.first.close == 0) return 0;
    return (priceChange / dataPoints.first.close) * 100;
  }

  /// Get average volume
  double get averageVolume {
    if (dataPoints.isEmpty) return 0;
    final totalVolume = dataPoints.fold<int>(0, (sum, p) => sum + p.volume);
    return totalVolume / dataPoints.length;
  }

  /// Get total volume
  int get totalVolume {
    return dataPoints.fold<int>(0, (sum, p) => sum + p.volume);
  }

  /// Get highest price in period
  double get highestPrice {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.map((p) => p.high).reduce((a, b) => a > b ? a : b);
  }

  /// Get lowest price in period
  double get lowestPrice {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.map((p) => p.low).reduce((a, b) => a < b ? a : b);
  }
}

/// Individual stock data point (OHLCV)
class StockDataPoint {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double adjustedClose;
  final int volume;

  const StockDataPoint({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.adjustedClose,
    required this.volume,
  });

  /// Get the daily price change
  double get dailyChange => close - open;

  /// Get the daily price change percentage
  double get dailyChangePercent => open != 0 ? (dailyChange / open) * 100 : 0;

  /// Is this a positive day (close > open)?
  bool get isPositive => close >= open;
}
