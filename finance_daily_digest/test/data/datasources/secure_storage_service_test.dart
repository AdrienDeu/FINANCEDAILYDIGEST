import 'package:finance_daily_digest/data/datasources/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorageService', () {
    late SecureStorageService service;

    setUp(() {
      service = SecureStorageService();
    });

    test('should be instantiated successfully', () {
      expect(service, isNotNull);
    });

    test('hasOpenRouterApiKey should return false initially', () async {
      // In test environment, storage is empty
      final hasKey = await service.hasOpenRouterApiKey();
      expect(hasKey, isFalse);
    });

    test('getOpenRouterApiKey should return null initially', () async {
      final key = await service.getOpenRouterApiKey();
      expect(key, isNull);
    });
  });
}
