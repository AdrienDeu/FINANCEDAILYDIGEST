import 'package:finance_daily_digest/data/datasources/exceptions/api_exception.dart';
import 'package:finance_daily_digest/data/datasources/http/dio_client.dart';
import 'package:finance_daily_digest/data/datasources/openrouter_datasource.dart';
import 'package:finance_daily_digest/data/datasources/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OpenRouterDataSource', () {
    late OpenRouterDataSource dataSource;

    setUp(() {
      // Create datasource with default clients
      dataSource = OpenRouterDataSource(
        dioClient: DioClient(
          enableLogging: false,
        ),
        secureStorage: SecureStorageService(),
      );
    });

    test('should be instantiated successfully', () {
      expect(dataSource, isNotNull);
    });

    test('generateCompletion should throw UnauthorizedException without API key',
        () async {
      // This should throw because no API key is configured
      expect(
        () async => await dataSource.generateCompletion(
          prompt: 'Test prompt',
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('vulgarizeArticle should throw UnauthorizedException without API key',
        () async {
      expect(
        () async => await dataSource.vulgarizeArticle(
          articleTitle: 'Test',
          articleContent: 'Content',
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test(
        'generateInvestmentSuggestions should throw UnauthorizedException without API key',
        () async {
      expect(
        () async => await dataSource.generateInvestmentSuggestions(
          newsDigest: 'Test digest',
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });
}
