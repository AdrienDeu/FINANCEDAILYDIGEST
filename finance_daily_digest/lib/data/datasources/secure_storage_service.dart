import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for API keys and sensitive data
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  // Storage keys
  static const String _openRouterApiKeyKey = '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';

  /// Save OpenRouter API key securely
  Future<void> saveOpenRouterApiKey(String apiKey) async {
    await _storage.write(
      key: _openRouterApiKeyKey,
      value: apiKey,
    );
  }

  /// Get OpenRouter API key
  Future<String?> getOpenRouterApiKey() async {
    return await _storage.read(key: _openRouterApiKeyKey);
  }

  /// Delete OpenRouter API key
  Future<void> deleteOpenRouterApiKey() async {
    await _storage.delete(key: _openRouterApiKeyKey);
  }

  /// Check if OpenRouter API key exists
  Future<bool> hasOpenRouterApiKey() async {
    final key = await getOpenRouterApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
