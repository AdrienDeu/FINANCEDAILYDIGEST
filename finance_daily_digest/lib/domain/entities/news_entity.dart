/// Enum representing news categories for filtering
enum NewsCategory {
  all,      // Show all news
  action,   // Actions/Stocks
  etf,      // ETFs
  obligation, // Bonds/Obligations
  general,  // General financial news
}

/// Domain entity representing a financial news article
class NewsEntity {
  final String id;
  final String title;
  final String? description;
  final String? url;
  final String? imageUrl;
  final String? source;
  final String? category;
  final DateTime publishedAt;
  final String? vulgarizedContent;
  final DateTime? vulgarizedAt;

  const NewsEntity({
    required this.id,
    required this.title,
    this.description,
    this.url,
    this.imageUrl,
    this.source,
    this.category,
    required this.publishedAt,
    this.vulgarizedContent,
    this.vulgarizedAt,
  });

  /// Check if vulgarized content exists and is not expired (24h TTL)
  bool get hasValidVulgarizedContent {
    if (vulgarizedContent == null || vulgarizedAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(vulgarizedAt!);
    return difference.inHours < 24;
  }

  NewsEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? url,
    String? imageUrl,
    String? source,
    String? category,
    DateTime? publishedAt,
    String? vulgarizedContent,
    DateTime? vulgarizedAt,
  }) {
    return NewsEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      category: category ?? this.category,
      publishedAt: publishedAt ?? this.publishedAt,
      vulgarizedContent: vulgarizedContent ?? this.vulgarizedContent,
      vulgarizedAt: vulgarizedAt ?? this.vulgarizedAt,
    );
  }
}
