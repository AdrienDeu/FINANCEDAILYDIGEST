import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/cache_service.dart';
import '../../data/datasources/marketaux_datasource.dart';
import '../../data/datasources/openrouter_datasource.dart';
import '../../data/datasources/yahoo_finance_datasource.dart';
export '../../data/datasources/yahoo_finance_datasource.dart' show TopMoverStock;
import '../../data/repositories/ai_repository_impl.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/entities/daily_digest_entity.dart';
import '../../domain/entities/news_entity.dart';
import '../../domain/entities/suggestion_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/entities/stock_chart_entity.dart';
import '../../domain/usecases/get_daily_digest_usecase.dart';
import '../../domain/usecases/get_stock_chart_usecase.dart';
import '../../domain/usecases/get_news_usecase.dart';
import '../../domain/usecases/get_suggestions_usecase.dart';
import '../../domain/usecases/vulgarize_article_usecase.dart';

// ==================== DATA SOURCES ====================

/// Provider for CacheService
final cacheServiceProvider = Provider<CacheService>((ref) {
  final service = CacheService();
  // Note: init() is called in main.dart before runApp
  return service;
});

/// Provider for MarketauxDataSource (news)
final marketauxDataSourceProvider = Provider<MarketauxDataSource>((ref) {
  return MarketauxDataSource();
});

/// Provider for YahooQuotesDataSource (market quotes)
final yahooQuotesDataSourceProvider = Provider<YahooQuotesDataSource>((ref) {
  return YahooQuotesDataSource();
});

/// Provider for OpenRouterDataSource
final openRouterDataSourceProvider = Provider<OpenRouterDataSource>((ref) {
  return OpenRouterDataSource();
});

// ==================== REPOSITORIES ====================

/// Provider for NewsRepository
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(
    marketauxDataSource: ref.watch(marketauxDataSourceProvider),
    yahooQuotesDataSource: ref.watch(yahooQuotesDataSourceProvider),
    cacheService: ref.watch(cacheServiceProvider),
  );
});

/// Provider for AIRepository
final aiRepositoryProvider = Provider<AIRepository>((ref) {
  return AIRepositoryImpl(
    openRouterDataSource: ref.watch(openRouterDataSourceProvider),
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

/// Provider for VulgarizeArticleUseCase
final vulgarizeArticleUseCaseProvider = Provider<VulgarizeArticleUseCase>((ref) {
  return VulgarizeArticleUseCase(ref.watch(aiRepositoryProvider));
});

/// Provider for GetSuggestionsUseCase
final getSuggestionsUseCaseProvider = Provider<GetSuggestionsUseCase>((ref) {
  return GetSuggestionsUseCase(ref.watch(aiRepositoryProvider));
});

/// Provider for GetStockChartUseCase
final getStockChartUseCaseProvider = Provider<GetStockChartUseCase>((ref) {
  return GetStockChartUseCase(
    ref.watch(yahooQuotesDataSourceProvider),
  );
});

// ==================== STATE PROVIDERS ====================

/// State provider for daily digest
final dailyDigestProvider =
    FutureProvider.autoDispose<DailyDigestEntity>((ref) async {
  final useCase = ref.watch(getDailyDigestUseCaseProvider);
  return await useCase.execute();
});

/// State provider for news list with region filter
/// Watches both category and region filters
final newsListProvider =
    FutureProvider.autoDispose<List<NewsEntity>>((ref) async {
  final useCase = ref.watch(getNewsUseCaseProvider);
  final region = ref.watch(newsRegionFilterProvider);
  final industry = ref.watch(newsIndustryFilterProvider);

  // Convert industry enum to string for the API
  final industryString = _getIndustryApiString(industry);

  return await useCase.execute(
    region: region,
    category: industry == NewsIndustry.all ? null : industryString,
  );
});

/// State provider for news refresh
final newsRefreshProvider = FutureProvider.autoDispose<List<NewsEntity>>((ref) async {
  final useCase = ref.watch(getNewsUseCaseProvider);
  final region = ref.watch(newsRegionFilterProvider);
  return await useCase.refresh(region: region);
});

/// State provider for vulgarizing an article
final vulgarizeArticleProvider =
    FutureProvider.autoDispose.family<NewsEntity, NewsEntity>((ref, news) async {
  final useCase = ref.watch(vulgarizeArticleUseCaseProvider);
  return await useCase.execute(news);
});

/// State provider for investment suggestions
final suggestionsProvider =
    FutureProvider.autoDispose<List<SuggestionEntity>>((ref) async {
  final useCase = ref.watch(getSuggestionsUseCaseProvider);
  return await useCase.execute();
});


/// State provider for news industry filter
/// Persists during session, defaults to 'all'
final newsIndustryFilterProvider = StateProvider<NewsIndustry>((ref) {
  return NewsIndustry.all;
});

/// State provider for news region filter
/// Persists during session, defaults to 'all'
final newsRegionFilterProvider = StateProvider<NewsRegion>((ref) {
  return NewsRegion.all;
});

String _getIndustryApiString(NewsIndustry industry) {
  switch (industry) {
    case NewsIndustry.all:
      return 'general'; // Assuming 'general' fetches all categories from the API
    case NewsIndustry.technology:
      return 'Technology';
    case NewsIndustry.industrials:
      return 'Industrials';
    case NewsIndustry.healthcare:
      return 'Healthcare';
    case NewsIndustry.financials:
      return 'Financial Services';
    case NewsIndustry.energy:
      return 'Energy';
    case NewsIndustry.materials:
      return 'Basic Materials';
    case NewsIndustry.telecom:
      return 'Telecom';
    case NewsIndustry.utilities:
      return 'Utilities';
  }
}

// ==================== STOCK CHART PROVIDERS ====================

/// Fallback symbols if top movers fetch fails
const List<String> fallbackStatsSymbols = [
  'AAPL',
  'MSFT',
  'GOOGL',
  'NVDA',
];

/// Provider for fetching top movers (gainers/losers) dynamically
final topMoversProvider = FutureProvider.autoDispose<List<TopMoverStock>>((ref) async {
  final dataSource = ref.watch(yahooQuotesDataSourceProvider);
  return await dataSource.fetchTopMovers(count: 10);
});

/// State provider for chart period filter
final chartPeriodProvider = StateProvider<ChartPeriod>((ref) {
  return ChartPeriod.oneMonth;
});

/// State provider for selected symbols
/// Initialized empty - will be populated by top movers or fallback
final selectedStatsSymbolsProvider = StateProvider<List<String>>((ref) {
  return <String>[];
});

/// State provider for chart view mode (price or volume)
final chartViewModeProvider = StateProvider<ChartViewMode>((ref) {
  return ChartViewMode.price;
});

/// View mode enum for charts
enum ChartViewMode {
  price,
  volume,
}

/// State provider for stock chart data
/// Watches period and symbols and fetches data accordingly
/// If no symbols selected, uses top movers automatically
final stockChartProvider = FutureProvider.autoDispose<Map<String, StockChartEntity>>((ref) async {
  final useCase = ref.watch(getStockChartUseCaseProvider);
  final period = ref.watch(chartPeriodProvider);
  var symbols = ref.watch(selectedStatsSymbolsProvider);

  // If no symbols selected, fetch top movers dynamically
  if (symbols.isEmpty) {
    final topMovers = await ref.watch(topMoversProvider.future);
    if (topMovers.isNotEmpty) {
      symbols = topMovers.take(4).map((m) => m.symbol).toList();
      // Update the state provider with the fetched symbols
      ref.read(selectedStatsSymbolsProvider.notifier).state = symbols;
    } else {
      // Fallback to default symbols if top movers fetch fails
      symbols = fallbackStatsSymbols;
      ref.read(selectedStatsSymbolsProvider.notifier).state = symbols;
    }
  }

  return await useCase.execute(
    symbols: symbols,
    period: period,
  );
});

/// State provider for refreshing stock charts
final stockChartRefreshProvider = FutureProvider.autoDispose<Map<String, StockChartEntity>>((ref) async {
  final useCase = ref.watch(getStockChartUseCaseProvider);
  final period = ref.watch(chartPeriodProvider);
  final symbols = ref.watch(selectedStatsSymbolsProvider);

  if (symbols.isEmpty) {
    return {};
  }

  return await useCase.refresh(
    symbols: symbols,
    period: period,
  );
});
