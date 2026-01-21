import '../entities/daily_digest_entity.dart';
import '../repositories/news_repository.dart';

/// Use case for getting the daily financial digest
class GetDailyDigestUseCase {
  final NewsRepository repository;

  const GetDailyDigestUseCase(this.repository);

  /// Execute the use case to get today's digest
  ///
  /// Behavior:
  /// 1. Check cache for today's digest
  /// 2. If cache exists and not expired (TTL 24h), return it
  /// 3. If cache expired or missing, fetch from API
  /// 4. Cache the new digest
  /// 5. Return the digest
  ///
  /// Throws exception if API call fails and no cache available
  Future<DailyDigestEntity> execute() async {
    return await repository.getDailyDigest();
  }
}
