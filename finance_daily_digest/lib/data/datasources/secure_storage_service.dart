import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for API keys and sensitive data
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  // Storage keys (identifiers, not values)
  static const String _openRouterApiKeyKey = 'openrouter_api_key';
  static const String _marketauxApiKeyKey = 'marketaux_api_key';

  // Default API keys (for personal use - in production, remove these)
  static const String _defaultOpenRouterApiKey =
      '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';
  static const String _defaultMarketauxApiKey =
      'kDtxbEj4nV7MKLiBS8uosgxh5vMKa3lkY7HY6WJb';

  /// Save OpenRouter API key securely
  Future<void> saveOpenRouterApiKey(String apiKey) async {
    await _storage.write(
      key: _openRouterApiKeyKey,
      value: apiKey,
    );
  }

  /// Get OpenRouter API key
  /// Returns the stored key or falls back to the default key
  Future<String?> getOpenRouterApiKey() async {
    final storedKey = await _storage.read(key: _openRouterApiKeyKey);
    if (storedKey != null && storedKey.isNotEmpty) {
      return storedKey;
    }
    // Fallback to default key for personal use
    return _defaultOpenRouterApiKey;
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

  // ==================== MARKETAUX API KEY ====================

  /// Save Marketaux API key securely
  Future<void> saveMarketauxApiKey(String apiKey) async {
    await _storage.write(
      key: _marketauxApiKeyKey,
      value: apiKey,
    );
  }

  /// Get Marketaux API key
  /// Returns the stored key or falls back to the default key
  Future<String?> getMarketauxApiKey() async {
    final storedKey = await _storage.read(key: _marketauxApiKeyKey);
    if (storedKey != null && storedKey.isNotEmpty) {
      return storedKey;
    }
    // Fallback to default key for personal use
    return _defaultMarketauxApiKey;
  }

  /// Delete Marketaux API key
  Future<void> deleteMarketauxApiKey() async {
    await _storage.delete(key: _marketauxApiKeyKey);
  }

  /// Check if Marketaux API key exists
  Future<bool> hasMarketauxApiKey() async {
    final key = await getMarketauxApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
