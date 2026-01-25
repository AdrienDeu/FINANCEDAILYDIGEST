import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../domain/entities/news_entity.dart';
import 'exceptions/api_exception.dart';
import 'http/dio_client.dart';
import 'secure_storage_service.dart';

/// Configuration for Marketaux API queries
class MarketauxConfig {
  /// Default countries for global market coverage
  static const List<String> defaultCountries = [
    'us', // United States
    'fr', // France
    'de', // Germany
    'gb', // United Kingdom
    'jp', // Japan
    'cn', // China
    'br', // Brazil (emerging)
    'in', // India (emerging)
  ];

  /// European countries
  static const List<String> europeCountries = [
    'fr', // France
    'de', // Germany
    'gb', // United Kingdom
    'it', // Italy
    'es', // Spain
    'nl', // Netherlands
    'ch', // Switzerland
    'be', // Belgium
  ];

  /// USA countries
  static const List<String> usaCountries = [
    'us', // United States
  ];

  /// Asian countries
  static const List<String> asiaCountries = [
    'jp', // Japan
    'cn', // China
    'kr', // South Korea
    'hk', // Hong Kong
    'sg', // Singapore
    'in', // India
    'tw', // Taiwan
  ];

  /// Get countries for a specific region
  static List<String> getCountriesForRegion(NewsRegion region) {
    switch (region) {
      case NewsRegion.europe:
        return europeCountries;
      case NewsRegion.usa:
        return usaCountries;
      case NewsRegion.asia:
        return asiaCountries;
      case NewsRegion.all:
        return defaultCountries;
    }
  }

  /// Languages for news content
  static const List<String> defaultLanguages = ['en', 'fr'];

  /// Key symbols to track
  static const List<String> defaultSymbols = [
    // US Tech Giants
    'AAPL', 'MSFT', 'GOOGL', 'AMZN', 'NVDA', 'META', 'TSLA',
    // French CAC 40
    'MC.PA', 'OR.PA', 'AIR.PA', 'BNP.PA', 'SAN.PA',
    // German DAX
    'SAP.DE', 'SIE.DE', 'BMW.DE',
    // UK FTSE
    'SHEL.L', 'HSBA.L',
    // Commodities (via companies)
    'XOM', 'CVX', // Oil
    // Crypto-related
    'COIN', 'MSTR',
  ];

  /// Industries of interest
  static const List<String> defaultIndustries = [
    'Technology',
    'Financial Services',
    'Healthcare',
    'Energy',
    'Industrials',
    'Basic Materials',
  ];
}

/// DataSource for Marketaux Financial News API
class MarketauxDataSource {
  final DioClient _dioClient;
  final SecureStorageService _secureStorage;

  static const String _baseUrl = 'https://api.marketaux.com/v1';

  MarketauxDataSource({
    DioClient? dioClient,
    SecureStorageService? secureStorage,
  })  : _dioClient = dioClient ??
            DioClient(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            ),
        _secureStorage = secureStorage ?? SecureStorageService();

  /// Fetch global financial news from Marketaux API
  ///
  /// [countries] - ISO country codes to filter by
  /// [languages] - Language codes for content
  /// [symbols] - Stock symbols to filter by
  /// [industries] - Industries to filter by
  /// [limit] - Number of results (default: 20)
  Future<List<Map<String, dynamic>>> fetchNews({
    List<String>? countries,
    List<String>? languages,
    List<String>? symbols,
    List<String>? industries,
    int limit = 20,
  }) async {
    try {
      developer.log('Fetching news from Marketaux API...');

      final apiToken = await _secureStorage.getMarketauxApiKey();
      if (apiToken == null || apiToken.isEmpty) {
        throw const ClientException(
          'Clé API Marketaux non configurée. Veuillez la configurer dans les paramètres.',
          401,
        );
      }

      final queryParams = <String, dynamic>{
        'api_token': apiToken,
        'limit': limit,
        'filter_entities': true,
      };

      // Add optional filters
      if (countries != null && countries.isNotEmpty) {
        queryParams['countries'] = countries.join(',');
      }
      if (languages != null && languages.isNotEmpty) {
        queryParams['languages'] = languages.join(',');
      }
      if (symbols != null && symbols.isNotEmpty) {
        queryParams['symbols'] = symbols.join(',');
      }
      if (industries != null && industries.isNotEmpty) {
        queryParams['industries'] = industries.join(',');
      }

      final response = await _dioClient.dio.get(
        '/news/all',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final articles = data['data'] as List<dynamic>? ?? [];

        developer.log('Fetched ${articles.length} articles from Marketaux');

        return articles.map((article) {
          return _mapMarketauxToInternal(article as Map<String, dynamic>);
        }).toList();
      }

      return [];
    } on DioException catch (e) {
      developer.log('Marketaux API error: ${e.message}');

      if (e.response?.statusCode == 429) {
        throw const RateLimitException(
          'Limite de requêtes Marketaux atteinte. Réessayez plus tard.',
        );
      }
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw const UnauthorizedException(
          'Clé API Marketaux invalide ou expirée.',
        );
      }
      if (e.response?.statusCode == 402) {
        throw const ClientException(
          'Quota Marketaux dépassé. Vérifiez votre plan.',
          402,
        );
      }

      if (e.error is ApiException) {
        throw e.error as ApiException;
      }

      throw NetworkException(
        'Erreur réseau Marketaux: ${e.message}',
      );
    } catch (e) {
      developer.log('Error fetching Marketaux news: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ParseException(
        'Erreur lors de la récupération des actualités: ${e.toString()}',
        e,
      );
    }
  }

  /// Fetch news for specific symbols
  Future<List<Map<String, dynamic>>> fetchSymbolNews({
    required List<String> symbols,
    int limit = 10,
  }) async {
    return fetchNews(
      symbols: symbols,
      limit: limit,
    );
  }

  /// Fetch news with default global configuration
  /// [region] - Optional region filter (europe, usa, asia, all)
  Future<List<Map<String, dynamic>>> fetchGlobalNews({
    int limit = 20,
    NewsRegion region = NewsRegion.all,
  }) async {
    final countries = MarketauxConfig.getCountriesForRegion(region);
    return fetchNews(
      countries: countries,
      languages: MarketauxConfig.defaultLanguages,
      limit: limit,
    );
  }

  /// Map Marketaux API response to internal app format
  Map<String, dynamic> _mapMarketauxToInternal(Map<String, dynamic> article) {
    final entities = article['entities'] as List<dynamic>? ?? [];

    // Extract symbols from entities
    final symbols = entities
        .map((e) => (e as Map<String, dynamic>)['symbol'] as String?)
        .whereType<String>()
        .toList();

    // Calculate average sentiment from entities
    double? avgSentiment;
    if (entities.isNotEmpty) {
      final sentiments = entities
          .map((e) => (e as Map<String, dynamic>)['sentiment_score'] as num?)
          .whereType<num>()
          .toList();
      if (sentiments.isNotEmpty) {
        avgSentiment =
            sentiments.reduce((a, b) => a + b) / sentiments.length.toDouble();
      }
    }

    // Determine category based on entities
    final category = _categorizeFromEntities(entities, article['title'] as String? ?? '');

    // Parse published date
    DateTime publishedAt;
    try {
      publishedAt = DateTime.parse(article['published_at'] as String);
    } catch (_) {
      publishedAt = DateTime.now();
    }

    return {
      'id': article['uuid'] as String? ?? '',
      'uuid': article['uuid'] as String? ?? '',
      'title': article['title'] as String? ?? '',
      'description': article['description'] as String?,
      'content': article['snippet'] as String?,
      'snippet': article['snippet'] as String?,
      'url': article['url'] as String?,
      'imageUrl': article['image_url'] as String?,
      'source': article['source'] as String?,
      'provider': article['source'] as String?,
      'publishedAt': publishedAt.toIso8601String(),
      'category': category,
      'sentimentScore': avgSentiment,
      'relevanceScore': article['relevance_score'] as double?,
      'relatedSymbols': symbols,
    };
  }

  /// Categorize news based on entity types and keywords
  String _categorizeFromEntities(List<dynamic> entities, String title) {
    final lowerTitle = title.toLowerCase();

    // Check entity types
    for (final entity in entities) {
      final entityMap = entity as Map<String, dynamic>;
      final type = entityMap['type'] as String? ?? '';
      final industry = entityMap['industry'] as String? ?? '';

      // Index type -> ETF category
      if (type.toLowerCase() == 'index') {
        return 'etf';
      }

      // Financial Services with bond-related keywords -> Obligation
      if (industry.toLowerCase().contains('financial')) {
        if (lowerTitle.contains('bond') ||
            lowerTitle.contains('treasury') ||
            lowerTitle.contains('yield') ||
            lowerTitle.contains('obligation') ||
            lowerTitle.contains('dette') ||
            lowerTitle.contains('taux')) {
          return 'obligation';
        }
      }
    }

    // Keyword-based categorization (fallback)
    if (lowerTitle.contains('etf') ||
        lowerTitle.contains('tracker') ||
        lowerTitle.contains('indice') ||
        lowerTitle.contains('msci') ||
        lowerTitle.contains('ishares')) {
      return 'etf';
    }

    if (lowerTitle.contains('obligation') ||
        lowerTitle.contains('bond') ||
        lowerTitle.contains('taux') ||
        lowerTitle.contains('rendement') ||
        lowerTitle.contains('dette') ||
        lowerTitle.contains('bce') ||
        lowerTitle.contains('fed') ||
        lowerTitle.contains('treasury')) {
      return 'obligation';
    }

    if (lowerTitle.contains('action') ||
        lowerTitle.contains('stock') ||
        lowerTitle.contains('share') ||
        lowerTitle.contains('bourse') ||
        lowerTitle.contains('cac') ||
        lowerTitle.contains('dax') ||
        lowerTitle.contains('s&p') ||
        lowerTitle.contains('nasdaq') ||
        entities.any((e) =>
            (e as Map<String, dynamic>)['type']?.toString().toLowerCase() ==
            'equity')) {
      return 'action';
    }

    return 'general';
  }
}
