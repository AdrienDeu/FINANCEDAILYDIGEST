import 'dart:developer' as developer;

import '../../data/datasources/yahoo_finance_datasource.dart';
import '../entities/stock_chart_entity.dart';

/// Use case for getting stock chart data from Yahoo Finance
class GetStockChartUseCase {
  final YahooQuotesDataSource _yahooDataSource;

  GetStockChartUseCase(this._yahooDataSource);

  /// Execute the use case to get stock chart data
  ///
  /// [symbols] - List of stock symbols to fetch charts for
  /// [period] - Time period for the chart
  Future<Map<String, StockChartEntity>> execute({
    required List<String> symbols,
    required ChartPeriod period,
  }) async {
    developer.log(
      'GetStockChartUseCase: Fetching charts for ${symbols.join(", ")} (period: ${period.apiValue})',
    );

    try {
      final responses = await _yahooDataSource.fetchMultipleCharts(
        symbols: symbols,
        range: period.apiValue,
        interval: '1d',
      );

      // Convert responses to entities
      final entities = <String, StockChartEntity>{};

      for (final entry in responses.entries) {
        final response = entry.value;
        entities[entry.key] = StockChartEntity(
          symbol: response.symbol,
          currency: response.currency,
          exchangeName: response.exchangeName,
          dataPoints: response.dataPoints
              .map((p) => StockDataPointEntity(
                    date: p.date,
                    open: p.open,
                    high: p.high,
                    low: p.low,
                    close: p.close,
                    adjustedClose: p.adjustedClose,
                    volume: p.volume,
                  ))
              .toList(),
        );
      }

      developer.log('Fetched chart data for ${entities.length} symbols');
      return entities;
    } catch (e) {
      developer.log('Error fetching stock charts: $e');
      rethrow;
    }
  }

  /// Refresh charts (same as execute, no caching for now)
  Future<Map<String, StockChartEntity>> refresh({
    required List<String> symbols,
    required ChartPeriod period,
  }) async {
    return execute(symbols: symbols, period: period);
  }
}
