import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'exceptions/api_exception.dart';
import 'http/dio_client.dart';

/// DataSource for Yahoo Finance - Fetches French financial news via RSS feeds
class YahooFinanceDataSource {
  final DioClient _dioClient;
  final Dio _rssDio;

  YahooFinanceDataSource({
    DioClient? dioClient,
    Dio? rssDio,
  })  : _dioClient = dioClient ??
            DioClient(
              baseUrl: 'https://query2.finance.yahoo.com',
            ),
        _rssDio = rssDio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Accept': 'application/rss+xml, application/xml, text/xml',
                'Accept-Language': 'fr-FR,fr;q=0.9',
              },
            ),);

  /// RSS feed URLs for French financial news
  static const List<String> _rssFeedUrls = [
    // CAC 40 news (main French index)
    'https://feeds.finance.yahoo.com/rss/2.0/headline?s=%5EFCHI&region=FR&lang=fr-FR',
    // Major French stocks
    'https://feeds.finance.yahoo.com/rss/2.0/headline?s=MC.PA&region=FR&lang=fr-FR', // LVMH
    'https://feeds.finance.yahoo.com/rss/2.0/headline?s=OR.PA&region=FR&lang=fr-FR', // L'Oreal
    'https://feeds.finance.yahoo.com/rss/2.0/headline?s=AIR.PA&region=FR&lang=fr-FR', // Airbus
    // ETFs
    'https://feeds.finance.yahoo.com/rss/2.0/headline?s=CAC.PA&region=FR&lang=fr-FR',
  ];

  /// Fetch financial news from Yahoo Finance France via RSS feeds
  ///
  /// [count] - Number of news items to fetch (default: 20)
  ///
  /// Returns a list of news articles as JSON
  Future<List<Map<String, dynamic>>> fetchNews({
    String region = 'FR',
    int count = 20,
  }) async {
    try {
      developer.log('Fetching French financial news from Yahoo Finance RSS...');

      final allArticles = <Map<String, dynamic>>[];
      final seenUrls = <String>{};

      // Fetch from multiple RSS feeds
      for (final feedUrl in _rssFeedUrls) {
        if (allArticles.length >= count) break;

        try {
          final articles = await _fetchRssFeed(feedUrl);

          for (final article in articles) {
            final url = article['url'] as String? ?? '';
            if (seenUrls.contains(url)) continue;

            seenUrls.add(url);
            allArticles.add(article);

            if (allArticles.length >= count) break;
          }
        } catch (e) {
          developer.log('Error fetching feed $feedUrl: $e');
          // Continue with other feeds
        }
      }

      developer.log('Fetched ${allArticles.length} news articles from RSS');

      if (allArticles.isEmpty) {
        developer.log('No articles from RSS, using fallback');
        return _createDefaultNews();
      }

      // Sort by date (most recent first)
      allArticles.sort((a, b) {
        final dateA = DateTime.tryParse(a['publishedAt'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['publishedAt'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      return allArticles.take(count).toList();
    } catch (e) {
      developer.log('Error fetching news: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ParseException(
        'Erreur lors de la récupération des actualités: ${e.toString()}',
        e,
      );
    }
  }

  /// Fetch and parse a single RSS feed
  Future<List<Map<String, dynamic>>> _fetchRssFeed(String feedUrl) async {
    final response = await _rssDio.get(feedUrl);

    if (response.statusCode == 200 && response.data != null) {
      final xml = response.data as String;
      return _parseRssXml(xml);
    }

    return [];
  }

  /// Parse RSS XML content into news articles
  List<Map<String, dynamic>> _parseRssXml(String xml) {
    final articles = <Map<String, dynamic>>[];

    try {
      // Find all <item> elements
      final itemPattern = RegExp(
        r'<item>(.*?)</item>',
        multiLine: true,
        dotAll: true,
      );

      final matches = itemPattern.allMatches(xml);

      for (final match in matches) {
        final itemContent = match.group(1) ?? '';

        // Extract fields
        final title = _extractXmlTag(itemContent, 'title');
        final link = _extractXmlTag(itemContent, 'link');
        final description = _extractXmlTag(itemContent, 'description');
        final pubDate = _extractXmlTag(itemContent, 'pubDate');
        final guid = _extractXmlTag(itemContent, 'guid');

        if (title.isEmpty || link.isEmpty) continue;

        // Clean URL (remove RSS tracking parameter)
        final cleanUrl = link.replaceAll(RegExp(r'\?\.tsrc=rss$'), '');

        // Parse date
        DateTime publishedAt;
        try {
          publishedAt = _parseRssDate(pubDate);
        } catch (_) {
          publishedAt = DateTime.now();
        }

        // Determine category
        final category = _categorizeNews(title);

        articles.add({
          'id': guid.isNotEmpty ? guid : _generateId(cleanUrl),
          'uuid': guid.isNotEmpty ? guid : _generateId(cleanUrl),
          'title': _cleanHtmlEntities(title),
          'description': _cleanHtmlEntities(description),
          'url': cleanUrl,
          'link': cleanUrl,
          'source': 'Yahoo Finance',
          'provider': 'Yahoo Finance',
          'publishedAt': publishedAt.toIso8601String(),
          'category': category,
        });
      }
    } catch (e) {
      developer.log('Error parsing RSS XML: $e');
    }

    return articles;
  }

  /// Extract content from an XML tag
  String _extractXmlTag(String content, String tagName) {
    // Try CDATA first
    final cdataPattern = RegExp(
      '<$tagName><!\\[CDATA\\[(.*?)\\]\\]></$tagName>',
      multiLine: true,
      dotAll: true,
    );
    final cdataMatch = cdataPattern.firstMatch(content);
    if (cdataMatch != null) {
      return cdataMatch.group(1)?.trim() ?? '';
    }

    // Try regular tag
    final tagPattern = RegExp(
      '<$tagName>(.*?)</$tagName>',
      multiLine: true,
      dotAll: true,
    );
    final tagMatch = tagPattern.firstMatch(content);
    if (tagMatch != null) {
      return tagMatch.group(1)?.trim() ?? '';
    }

    return '';
  }

  /// Parse RSS date format (RFC 822)
  DateTime _parseRssDate(String dateStr) {
    // RSS date format: "Tue, 24 Jun 2025 08:04:08 +0000"
    if (dateStr.isEmpty) return DateTime.now();

    try {
      // Remove day name and parse
      final parts = dateStr.split(' ');
      if (parts.length >= 5) {
        final day = int.parse(parts[1]);
        final monthStr = parts[2];
        final year = int.parse(parts[3]);
        final timeParts = parts[4].split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final second = int.parse(timeParts[2]);

        final months = {
          'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
          'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
        };
        final month = months[monthStr] ?? 1;

        return DateTime.utc(year, month, day, hour, minute, second);
      }
    } catch (e) {
      developer.log('Error parsing date: $dateStr - $e');
    }

    return DateTime.now();
  }

  /// Clean HTML entities from text
  String _cleanHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&euro;', '€')
        .replaceAll('&#x27;', "'")
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove any HTML tags
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Categorize news based on keywords
  String _categorizeNews(String title) {
    final lowerTitle = title.toLowerCase();

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
        lowerTitle.contains('fed')) {
      return 'obligation';
    }
    if (lowerTitle.contains('action') ||
        lowerTitle.contains('cac') ||
        lowerTitle.contains('bourse') ||
        lowerTitle.contains('titre') ||
        lowerTitle.contains('lvmh') ||
        lowerTitle.contains('total') ||
        lowerTitle.contains('airbus') ||
        lowerTitle.contains('bnp') ||
        lowerTitle.contains('société générale') ||
        lowerTitle.contains('sanofi') ||
        lowerTitle.contains('l\'oréal') ||
        lowerTitle.contains('loreal') ||
        lowerTitle.contains('dégradé') ||
        lowerTitle.contains('relève') ||
        lowerTitle.contains('recommandation')) {
      return 'action';
    }

    return 'general';
  }

  /// Generate a unique ID from URL
  String _generateId(String url) {
    final hash = url.hashCode.abs().toString();
    return 'news_$hash';
  }

  /// Create default news items when RSS fails
  List<Map<String, dynamic>> _createDefaultNews() {
    final now = DateTime.now();
    return [
      {
        'id': 'default_cac40_${now.millisecondsSinceEpoch}',
        'uuid': 'default_cac40_${now.millisecondsSinceEpoch}',
        'title': 'CAC 40 : Suivi des marchés européens',
        'description':
            'Suivez l\'évolution du CAC 40 et des principaux indices européens en temps réel.',
        'url': 'https://fr.finance.yahoo.com/quote/%5EFCHI/',
        'link': 'https://fr.finance.yahoo.com/quote/%5EFCHI/',
        'source': 'Yahoo Finance',
        'provider': 'Yahoo Finance',
        'publishedAt': now.toIso8601String(),
        'category': 'action',
      },
      {
        'id': 'default_euro_${now.millisecondsSinceEpoch}',
        'uuid': 'default_euro_${now.millisecondsSinceEpoch}',
        'title': 'EUR/USD : Taux de change Euro Dollar',
        'description':
            'Suivez l\'évolution du taux de change entre l\'euro et le dollar américain.',
        'url': 'https://fr.finance.yahoo.com/quote/EURUSD=X/',
        'link': 'https://fr.finance.yahoo.com/quote/EURUSD=X/',
        'source': 'Yahoo Finance',
        'provider': 'Yahoo Finance',
        'publishedAt': now.toIso8601String(),
        'category': 'general',
      },
      {
        'id': 'default_etf_${now.millisecondsSinceEpoch}',
        'uuid': 'default_etf_${now.millisecondsSinceEpoch}',
        'title': 'ETF Europe : Les trackers PEA à surveiller',
        'description':
            'Découvrez les ETF européens éligibles au PEA pour diversifier votre portefeuille.',
        'url': 'https://fr.finance.yahoo.com/etf/',
        'link': 'https://fr.finance.yahoo.com/etf/',
        'source': 'Yahoo Finance',
        'provider': 'Yahoo Finance',
        'publishedAt': now.toIso8601String(),
        'category': 'etf',
      },
    ];
  }

  /// Fetch news for a specific symbol
  Future<List<Map<String, dynamic>>> fetchSymbolNews({
    required String symbol,
    int count = 10,
  }) async {
    try {
      final feedUrl =
          'https://feeds.finance.yahoo.com/rss/2.0/headline?s=$symbol&region=FR&lang=fr-FR';
      return await _fetchRssFeed(feedUrl);
    } catch (e) {
      developer.log('Error fetching symbol news: $e');
      return [];
    }
  }

  /// Fetch market summary for European markets
  Future<Map<String, dynamic>> fetchEuropeanMarketSummary() async {
    try {
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
          return result[0] as Map<String, dynamic>;
        }
      }

      throw const ParseException('Format de réponse invalide');
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ClientException(
        e.message ?? 'Erreur lors de la récupération du résumé de marché',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ParseException(
        'Erreur de parsing: ${e.toString()}',
        e,
      );
    }
  }
}
