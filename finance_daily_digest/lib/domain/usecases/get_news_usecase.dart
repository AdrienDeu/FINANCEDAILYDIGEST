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
  ///
  /// Behavior:
  /// 1. Check cache for news (TTL 1h)
  /// 2. If cache valid, return cached news
  /// 3. If cache expired, fetch from API
  /// 4. Filter by European market (region=FR)
  /// 5. Cache and return news
  Future<List<NewsEntity>> execute({String? category}) async {
    return await repository.getNews(category: category);
  }

  /// Refresh news from API (invalidates cache)
  Future<List<NewsEntity>> refresh() async {
    return await repository.refreshNews();
  }
}
