import 'package:hive/hive.dart';

part 'news_model.g.dart';

@HiveType(typeId: 0)
class NewsModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? content;

  @HiveField(4)
  final String? url;

  @HiveField(5)
  final String? imageUrl;

  @HiveField(6)
  final String? source;

  @HiveField(7)
  final DateTime publishedAt;

  @HiveField(8)
  final String? category;

  @HiveField(9)
  final String? symbol;

  @HiveField(10)
  final DateTime cachedAt;

  @HiveField(11)
  final String? vulgarizedContent;

  @HiveField(12)
  final DateTime? vulgarizedAt;

  @HiveField(13)
  final double? sentimentScore;

  @HiveField(14)
  final List<String>? relatedSymbols;

  @HiveField(15)
  final String? snippet;

  NewsModel({
    required this.id,
    required this.title,
    this.description,
    this.content,
    this.url,
    this.imageUrl,
    this.source,
    required this.publishedAt,
    this.category,
    this.symbol,
    required this.cachedAt,
    this.vulgarizedContent,
    this.vulgarizedAt,
    this.sentimentScore,
    this.relatedSymbols,
    this.snippet,
  });

  /// Check if the news cache is expired (1 hour TTL)
  bool get isCacheExpired {
    final now = DateTime.now();
    final difference = now.difference(cachedAt);
    return difference.inHours >= 1;
  }

  /// Check if vulgarized content is expired (24 hours TTL)
  bool get isVulgarizedExpired {
    if (vulgarizedAt == null) return true;
    final now = DateTime.now();
    final difference = now.difference(vulgarizedAt!);
    return difference.inHours >= 24;
  }

  /// Create a copy with updated vulgarized content
  NewsModel copyWithVulgarized({
    required String vulgarizedContent,
  }) {
    return NewsModel(
      id: id,
      title: title,
      description: description,
      content: content,
      url: url,
      imageUrl: imageUrl,
      source: source,
      publishedAt: publishedAt,
      category: category,
      symbol: symbol,
      cachedAt: cachedAt,
      vulgarizedContent: vulgarizedContent,
      vulgarizedAt: DateTime.now(),
      sentimentScore: sentimentScore,
      relatedSymbols: relatedSymbols,
      snippet: snippet,
    );
  }

  /// Create from JSON (from API - supports both Yahoo and Marketaux formats)
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    // Parse related symbols from Marketaux format
    List<String>? relatedSymbols;
    if (json['relatedSymbols'] != null) {
      relatedSymbols = (json['relatedSymbols'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    }

    return NewsModel(
      id: json['id'] as String? ?? json['uuid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      content: json['content'] as String?,
      url: json['url'] as String?,
      imageUrl: json['imageUrl'] as String? ?? json['thumbnail'] as String?,
      source: json['source'] as String? ?? json['provider'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : DateTime.now(),
      category: json['category'] as String?,
      symbol: json['symbol'] as String?,
      cachedAt: DateTime.now(),
      sentimentScore: (json['sentimentScore'] as num?)?.toDouble(),
      relatedSymbols: relatedSymbols,
      snippet: json['snippet'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'imageUrl': imageUrl,
      'source': source,
      'publishedAt': publishedAt.toIso8601String(),
      'category': category,
      'symbol': symbol,
      'cachedAt': cachedAt.toIso8601String(),
      'vulgarizedContent': vulgarizedContent,
      'vulgarizedAt': vulgarizedAt?.toIso8601String(),
      'sentimentScore': sentimentScore,
      'relatedSymbols': relatedSymbols,
      'snippet': snippet,
    };
  }

  /// Get sentiment label for UI display
  String get sentimentLabel {
    if (sentimentScore == null) return 'Neutre';
    if (sentimentScore! > 0.3) return 'Positif';
    if (sentimentScore! < -0.3) return 'Négatif';
    return 'Neutre';
  }
}
