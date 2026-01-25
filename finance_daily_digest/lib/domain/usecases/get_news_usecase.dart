import '../entities/news_entity.dart';
import '../repositories/news_repository.dart';

/// Use case for getting financial news
class GetNewsUseCase {
  final NewsRepository repository;

  const GetNewsUseCase(this.repository);

  /// Execute the use case to get news list
  ///
  /// Parameters:
  /// - [category]: Optional category filter (Actions, ETF, Obligations)
  /// - [region]: Optional region filter (Europe, USA, Asia, All)
  ///
  /// Behavior:
  /// 1. Check cache for news (TTL 1h) - only if region is 'all'
  /// 2. If cache valid, return cached news
  /// 3. If cache expired or specific region, fetch from API
  /// 4. Filter by region and category
  /// 5. Cache (if all regions) and return news
  Future<List<NewsEntity>> execute({String? category, NewsRegion? region}) async {
    return await repository.getNews(category: category, region: region);
  }

  /// Refresh news from API (invalidates cache)
  /// [region]: Optional region filter
  Future<List<NewsEntity>> refresh({NewsRegion? region}) async {
    return await repository.refreshNews(region: region);
  }
}
