/// Domain entity representing an investment suggestion
class SuggestionEntity {
  final String id;
  final String ticker;
  final String name;
  final String type; // Action, ETF, Obligation
  final String reasoning;
  final String risk; // Faible, Moyen, Élevé
  final bool peaEligible;
  final DateTime createdAt;

  const SuggestionEntity({
    required this.id,
    required this.ticker,
    required this.name,
    required this.type,
    required this.reasoning,
    required this.risk,
    required this.peaEligible,
    required this.createdAt,
  });

  SuggestionEntity copyWith({
    String? id,
    String? ticker,
    String? name,
    String? type,
    String? reasoning,
    String? risk,
    bool? peaEligible,
    DateTime? createdAt,
  }) {
    return SuggestionEntity(
      id: id ?? this.id,
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      type: type ?? this.type,
      reasoning: reasoning ?? this.reasoning,
      risk: risk ?? this.risk,
      peaEligible: peaEligible ?? this.peaEligible,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
