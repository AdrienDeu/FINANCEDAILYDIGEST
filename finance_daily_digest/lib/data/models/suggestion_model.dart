import 'package:hive/hive.dart';

part 'suggestion_model.g.dart';

@HiveType(typeId: 1)
class SuggestionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String ticker;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String type; // Action, ETF, Obligation

  @HiveField(4)
  final String reasoning;

  @HiveField(5)
  final String risk; // Faible, Moyen, Élevé

  @HiveField(6)
  final bool peaEligible;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime cachedAt;

  @HiveField(9)
  final String? relatedNewsId;

  SuggestionModel({
    required this.id,
    required this.ticker,
    required this.name,
    required this.type,
    required this.reasoning,
    required this.risk,
    this.peaEligible = true,
    required this.createdAt,
    required this.cachedAt,
    this.relatedNewsId,
  });

  /// Check if the suggestion cache is expired (24 hours TTL)
  bool get isCacheExpired {
    final now = DateTime.now();
    final difference = now.difference(cachedAt);
    return difference.inHours >= 24;
  }

  /// Create from JSON (from AI response)
  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      id: json['id'] as String? ?? DateTime.now().toIso8601String(),
      ticker: json['ticker'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'Action',
      reasoning: json['reasoning'] as String? ?? '',
      risk: json['risk'] as String? ?? 'Moyen',
      peaEligible: json['peaEligible'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      cachedAt: DateTime.now(),
      relatedNewsId: json['relatedNewsId'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticker': ticker,
      'name': name,
      'type': type,
      'reasoning': reasoning,
      'risk': risk,
      'peaEligible': peaEligible,
      'createdAt': createdAt.toIso8601String(),
      'cachedAt': cachedAt.toIso8601String(),
      'relatedNewsId': relatedNewsId,
    };
  }
}
