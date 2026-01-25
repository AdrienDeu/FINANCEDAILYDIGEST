import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'exceptions/api_exception.dart';
import 'http/dio_client.dart';

/// DataSource for Yahoo Finance - Market Quotes Only
///
/// This datasource is used only for fetching market summary/quotes.
/// News fetching has been migrated to MarketauxDataSource.
class YahooQuotesDataSource {
  final DioClient _dioClient;

  YahooQuotesDataSource({
    DioClient? dioClient,
  }) : _dioClient = dioClient ??
            DioClient(
              baseUrl: 'https://query2.finance.yahoo.com',
            );

  /// Fetch market summary for European markets
  Future<Map<String, dynamic>> fetchEuropeanMarketSummary() async {
    try {
      developer.log('Fetching European market summary from Yahoo Finance...');

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
          developer.log('Market summary fetched successfully');
          return result[0] as Map<String, dynamic>;
        }
      }

      throw const ParseException('Format de réponse invalide');
    } on DioException catch (e) {
      developer.log('Yahoo Finance API error: ${e.message}');

      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ClientException(
        e.message ?? 'Erreur lors de la récupération du résumé de marché',
        e.response?.statusCode,
      );
    } catch (e) {
      developer.log('Error fetching market summary: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ParseException(
        'Erreur de parsing: ${e.toString()}',
        e,
      );
    }
  }

  /// Fetch quotes for specific symbols
  Future<List<Map<String, dynamic>>> fetchQuotes(List<String> symbols) async {
    try {
      developer.log('Fetching quotes for ${symbols.length} symbols...');

      final response = await _dioClient.dio.get(
        '/v6/finance/quote',
        queryParameters: {
          'symbols': symbols.join(','),
          'region': 'FR',
          'lang': 'fr-FR',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final quoteResponse = data['quoteResponse'] as Map<String, dynamic>?;
        final result = quoteResponse?['result'] as List?;

        if (result != null) {
          developer.log('Fetched ${result.length} quotes');
          return result.cast<Map<String, dynamic>>();
        }
      }

      return [];
    } on DioException catch (e) {
      developer.log('Yahoo Finance quotes error: ${e.message}');

      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ClientException(
        e.message ?? 'Erreur lors de la récupération des quotes',
        e.response?.statusCode,
      );
    } catch (e) {
      developer.log('Error fetching quotes: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ParseException(
        'Erreur de parsing: ${e.toString()}',
        e,
      );
    }
  }
}
