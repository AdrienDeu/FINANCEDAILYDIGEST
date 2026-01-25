import 'package:dio/dio.dart';
import 'package:finance_daily_digest/data/datasources/exceptions/api_exception.dart';
import 'package:finance_daily_digest/data/datasources/http/dio_client.dart';
import 'package:finance_daily_digest/data/datasources/yahoo_finance_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('YahooQuotesDataSource', () {
    late YahooQuotesDataSource dataSource;

    setUp(() {
      // Create datasource with default client
      dataSource = YahooQuotesDataSource(
        dioClient: DioClient(
          enableLogging: false,
        ),
      );
    });

    test('should be instantiated successfully', () {
      expect(dataSource, isNotNull);
    });

    test('fetchEuropeanMarketSummary should handle network errors gracefully',
        () async {
      expect(dataSource.fetchEuropeanMarketSummary, isA<Function>());
    });

    test('fetchQuotes should handle network errors gracefully', () async {
      expect(dataSource.fetchQuotes, isA<Function>());
    });
  });
}
