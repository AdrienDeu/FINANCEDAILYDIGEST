import 'package:dio/dio.dart';

import 'exceptions/api_exception.dart';
import 'http/dio_client.dart';

/// DataSource for Yahoo Finance API
class YahooFinanceDataSource {
  final DioClient _dioClient;

  YahooFinanceDataSource({
    DioClient? dioClient,
  }) : _dioClient = dioClient ??
            DioClient(
              baseUrl: 'https://query2.finance.yahoo.com',
            );

  /// Fetch financial news from Yahoo Finance
  ///
  /// [region] - Market region (e.g., 'FR' for France, 'US' for United States)
  /// [count] - Number of news items to fetch (default: 10)
  ///
  /// Returns a list of news articles as JSON
  Future<List<Map<String, dynamic>>> fetchNews({
    String region = 'FR',
    int count = 10,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/v1/finance/trending/$region',
        queryParameters: {
          'count': count,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final finance = data['finance'] as Map<String, dynamic>?;
        final result = finance?['result'] as List?;

        if (result != null && result.isNotEmpty) {
          final quotes = result[0]['quotes'] as List?;
          if (quotes != null) {
            return quotes.cast<Map<String, dynamic>>();
          }
        }
      }

      throw const ParseException('Format de réponse invalide');
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ClientException(
        e.message ?? 'Erreur lors de la récupération des actualités',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ParseException(
        'Erreur de parsing: ${e.toString()}',
        e,
      );
    }
  }

  /// Fetch news for a specific symbol
  ///
  /// [symbol] - Stock symbol (e.g., 'CAC40.PA' for CAC 40)
  /// [count] - Number of news items to fetch
  Future<List<Map<String, dynamic>>> fetchSymbolNews({
    required String symbol,
    int count = 10,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/v1/finance/search',
        queryParameters: {
          'q': symbol,
          'newsCount': count,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final news = data['news'] as List?;

        if (news != null) {
          return news.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ClientException(
        e.message ?? 'Erreur lors de la récupération des actualités',
        e.response?.statusCode,
      );
    } catch (e) {
      throw ParseException(
        'Erreur de parsing: ${e.toString()}',
        e,
      );
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
