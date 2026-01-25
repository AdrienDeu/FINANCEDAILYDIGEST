/// Enum representing news categories for filtering
enum NewsCategory {
  all,      // Show all news
  action,   // Actions/Stocks
  etf,      // ETFs
  obligation, // Bonds/Obligations
  general,  // General financial news
}

/// Enum representing geographic regions for filtering news
enum NewsRegion {
  all,      // All regions (global)
  france,   // France only
  europe,   // European markets (DE, IT, ES, etc. - excluding FR)
  usa,      // United States markets
  asia,     // Asian markets (JP, CN, KR, etc.)
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
  final double? sentimentScore;
  final List<String>? relatedSymbols;
  final String? snippet;

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
    this.sentimentScore,
    this.relatedSymbols,
    this.snippet,
  });

  /// Check if vulgarized content exists and is not expired (24h TTL)
  bool get hasValidVulgarizedContent {
    if (vulgarizedContent == null || vulgarizedAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(vulgarizedAt!);
    return difference.inHours < 24;
  }

  /// Get sentiment label for UI display
  String get sentimentLabel {
    if (sentimentScore == null) return 'Neutre';
    if (sentimentScore! > 0.3) return 'Positif';
    if (sentimentScore! < -0.3) return 'Négatif';
    return 'Neutre';
  }

  /// Check if sentiment is positive
  bool get isPositiveSentiment => sentimentScore != null && sentimentScore! > 0.3;

  /// Check if sentiment is negative
  bool get isNegativeSentiment => sentimentScore != null && sentimentScore! < -0.3;

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
    double? sentimentScore,
    List<String>? relatedSymbols,
    String? snippet,
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
      sentimentScore: sentimentScore ?? this.sentimentScore,
      relatedSymbols: relatedSymbols ?? this.relatedSymbols,
      snippet: snippet ?? this.snippet,
    );
  }
}
