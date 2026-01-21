import '../entities/news_entity.dart';
import '../repositories/ai_repository.dart';

/// Use case for vulgarizing financial articles using AI
class VulgarizeArticleUseCase {
  final AIRepository repository;

  const VulgarizeArticleUseCase(this.repository);

  /// Execute the use case to vulgarize an article
  ///
  /// Parameters:
  /// - [news]: The news article to vulgarize
  ///
  /// Behavior:
  /// 1. Check if article already has valid vulgarized content (TTL 24h)
  /// 2. If yes, return the news as-is
  /// 3. If no, call OpenRouter AI to vulgarize
  /// 4. Cache the vulgarized content
  /// 5. Return updated news entity
  ///
  /// Throws exception if AI call fails and no cached content available
  Future<NewsEntity> execute(NewsEntity news) async {
    // Check if already vulgarized and not expired
    if (news.hasValidVulgarizedContent) {
      return news;
    }

    // Call AI to vulgarize
    return await repository.vulgarizeArticle(news);
  }
}
