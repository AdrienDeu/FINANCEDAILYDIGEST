import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/cache_service.dart';
import '../../data/datasources/yahoo_finance_datasource.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/entities/daily_digest_entity.dart';
import '../../domain/entities/news_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/usecases/get_daily_digest_usecase.dart';
import '../../domain/usecases/get_news_usecase.dart';

// ==================== DATA SOURCES ====================

/// Provider for CacheService
final cacheServiceProvider = Provider<CacheService>((ref) {
  final service = CacheService();
  // Note: init() is called in main.dart before runApp
  return service;
});

/// Provider for YahooFinanceDataSource
final yahooFinanceDataSourceProvider = Provider<YahooFinanceDataSource>((ref) {
  return YahooFinanceDataSource();
});

// ==================== REPOSITORIES ====================

/// Provider for NewsRepository
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(
    yahooDataSource: ref.watch(yahooFinanceDataSourceProvider),
    cacheService: ref.watch(cacheServiceProvider),
  );
});

// ==================== USE CASES ====================

/// Provider for GetDailyDigestUseCase
final getDailyDigestUseCaseProvider = Provider<GetDailyDigestUseCase>((ref) {
  return GetDailyDigestUseCase(ref.watch(newsRepositoryProvider));
});

/// Provider for GetNewsUseCase
final getNewsUseCaseProvider = Provider<GetNewsUseCase>((ref) {
  return GetNewsUseCase(ref.watch(newsRepositoryProvider));
});

// ==================== STATE PROVIDERS ====================

/// State provider for daily digest
final dailyDigestProvider =
    FutureProvider.autoDispose<DailyDigestEntity>((ref) async {
  final useCase = ref.watch(getDailyDigestUseCaseProvider);
  return await useCase.execute();
});

/// State provider for news list
final newsListProvider =
    FutureProvider.autoDispose.family<List<NewsEntity>, String?>((ref, category) async {
  final useCase = ref.watch(getNewsUseCaseProvider);
  return await useCase.execute(category: category);
});

/// State provider for news refresh
final newsRefreshProvider = FutureProvider.autoDispose<List<NewsEntity>>((ref) async {
  final useCase = ref.watch(getNewsUseCaseProvider);
  return await useCase.refresh();
});
