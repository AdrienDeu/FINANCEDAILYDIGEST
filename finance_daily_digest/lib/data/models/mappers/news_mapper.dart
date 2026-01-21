import '../../../domain/entities/news_entity.dart';
import '../news_model.dart';

/// Extension to convert between NewsModel and NewsEntity
extension NewsModelMapper on NewsModel {
  /// Convert NewsModel to NewsEntity
  NewsEntity toEntity() {
    return NewsEntity(
      id: id,
      title: title,
      description: description,
      url: url,
      imageUrl: imageUrl,
      source: source,
      category: category,
      publishedAt: publishedAt,
      vulgarizedContent: vulgarizedContent,
      vulgarizedAt: vulgarizedAt,
    );
  }
}

extension NewsEntityMapper on NewsEntity {
  /// Convert NewsEntity to NewsModel
  NewsModel toModel() {
    return NewsModel(
      id: id,
      title: title,
      description: description,
      url: url,
      imageUrl: imageUrl,
      source: source,
      category: category,
      publishedAt: publishedAt,
      cachedAt: DateTime.now(),
      vulgarizedContent: vulgarizedContent,
      vulgarizedAt: vulgarizedAt,
    );
  }
}
