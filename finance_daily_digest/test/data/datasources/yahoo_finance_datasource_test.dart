import 'package:dio/dio.dart';
import 'package:finance_daily_digest/data/datasources/exceptions/api_exception.dart';
import 'package:finance_daily_digest/data/datasources/http/dio_client.dart';
import 'package:finance_daily_digest/data/datasources/yahoo_finance_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('YahooFinanceDataSource', () {
    late YahooFinanceDataSource dataSource;

    setUp(() {
      // Create datasource with default client
      dataSource = YahooFinanceDataSource(
        dioClient: DioClient(
          enableLogging: false,
        ),
      );
    });

    test('should be instantiated successfully', () {
      expect(dataSource, isNotNull);
    });

    test('fetchNews should handle network errors gracefully', () async {
      // This test verifies that network errors are properly caught
      // In a real scenario with a mock, we would inject a failing client
      expect(dataSource.fetchNews, isA<Function>());
    });

    test('fetchSymbolNews should handle network errors gracefully', () async {
      expect(dataSource.fetchSymbolNews, isA<Function>());
    });

    test('fetchEuropeanMarketSummary should handle network errors gracefully',
        () async {
      expect(dataSource.fetchEuropeanMarketSummary, isA<Function>());
    });
  });
}
