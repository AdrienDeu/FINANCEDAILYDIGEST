import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../exceptions/api_exception.dart';

/// Configured Dio client with interceptors
class DioClient {
  late final Dio _dio;

  DioClient({
    String? baseUrl,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 30),
    bool enableLogging = true,
    int maxRetries = 3,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    if (enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
        ),
      );
    }

    // Add retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        maxRetries: maxRetries,
      ),
    );

    // Add error handling interceptor
    _dio.interceptors.add(
      ErrorHandlingInterceptor(),
    );
  }

  Dio get dio => _dio;
}

/// Retry interceptor with exponential backoff
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] as int? ?? 0;

    // Only retry on network errors or 5xx server errors
    final shouldRetry = _shouldRetry(err) && retryCount < maxRetries;

    if (shouldRetry) {
      extra['retryCount'] = retryCount + 1;

      // Exponential backoff: 500ms, 1s, 2s
      final delayMs = 500 * (1 << retryCount);
      await Future.delayed(Duration(milliseconds: delayMs));

      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}

/// Error handling interceptor
class ErrorHandlingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }

  ApiException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          if (statusCode == 401) {
            return const UnauthorizedException();
          } else if (statusCode == 429) {
            return const RateLimitException();
          } else if (statusCode >= 500) {
            return ServerException(
              'Erreur serveur',
              statusCode,
            );
          } else if (statusCode >= 400) {
            return ClientException(
              error.response?.data?['message'] as String? ??
                  'Erreur client',
              statusCode,
            );
          }
        }
        return ServerException('Erreur serveur', statusCode);

      case DioExceptionType.connectionError:
        if (error.error is SocketException) {
          return const NetworkException();
        }
        return const NetworkException('Erreur de connexion');

      case DioExceptionType.cancel:
        return const ClientException('Requête annulée');

      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return const NetworkException();
        }
        return ClientException(
          error.message ?? 'Erreur inconnue',
          error.response?.statusCode,
        );
    }
  }
}
