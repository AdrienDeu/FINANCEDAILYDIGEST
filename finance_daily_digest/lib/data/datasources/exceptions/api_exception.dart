/// Base exception for API-related errors
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const ApiException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// Network connectivity exception
class NetworkException extends ApiException {
  const NetworkException([
    String message = 'Aucune connexion internet disponible',
  ]) : super(message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Server error exception (5xx)
class ServerException extends ApiException {
  const ServerException([
    String message = 'Erreur serveur',
    int? statusCode,
  ]) : super(message, statusCode: statusCode);

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Client error exception (4xx)
class ClientException extends ApiException {
  const ClientException([
    String message = 'Erreur client',
    int? statusCode,
  ]) : super(message, statusCode: statusCode);

  @override
  String toString() => 'ClientException: $message (status: $statusCode)';
}

/// Unauthorized exception (401)
class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    String message = 'Non autorisé - clé API invalide',
  ]) : super(message, statusCode: 401);
}

/// Timeout exception
class TimeoutException extends ApiException {
  const TimeoutException([
    String message = 'Délai d\'attente dépassé',
  ]) : super(message);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Rate limit exceeded exception (429)
class RateLimitException extends ApiException {
  const RateLimitException([
    String message = 'Trop de requêtes - veuillez patienter',
  ]) : super(message, statusCode: 429);
}

/// Parse exception
class ParseException extends ApiException {
  const ParseException([
    String message = 'Erreur de parsing des données',
    dynamic originalError,
  ]) : super(message, originalError: originalError);

  @override
  String toString() => 'ParseException: $message';
}
