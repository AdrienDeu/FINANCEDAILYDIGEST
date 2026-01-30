/// Domain entity for entity statistics
class EntityStatsEntity {
  final String symbol;
  final DateTime date;
  final int totalDocuments;
  final double sentimentAvg;

  const EntityStatsEntity({
    required this.symbol,
    required this.date,
    required this.totalDocuments,
    required this.sentimentAvg,
  });

  /// Get sentiment category based on value
  /// Positive: > 0.2, Negative: < -0.2, Neutral: between
  SentimentCategory get sentimentCategory {
    if (sentimentAvg > 0.2) return SentimentCategory.positive;
    if (sentimentAvg < -0.2) return SentimentCategory.negative;
    return SentimentCategory.neutral;
  }

  /// Get sentiment label in French
  String get sentimentLabel {
    switch (sentimentCategory) {
      case SentimentCategory.positive:
        return 'Positif';
      case SentimentCategory.negative:
        return 'Négatif';
      case SentimentCategory.neutral:
        return 'Neutre';
    }
  }

  @override
  String toString() {
    return 'EntityStatsEntity(symbol: $symbol, date: $date, totalDocuments: $totalDocuments, sentimentAvg: $sentimentAvg)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntityStatsEntity &&
        other.symbol == symbol &&
        other.date == date &&
        other.totalDocuments == totalDocuments &&
        other.sentimentAvg == sentimentAvg;
  }

  @override
  int get hashCode {
    return symbol.hashCode ^
        date.hashCode ^
        totalDocuments.hashCode ^
        sentimentAvg.hashCode;
  }
}

/// Sentiment category enum
enum SentimentCategory {
  positive,
  neutral,
  negative,
}

/// Statistics period enum
enum StatsPeriod {
  sevenDays(7, '7j'),
  thirtyDays(30, '30j'),
  ninetyDays(90, '90j');

  final int days;
  final String label;

  const StatsPeriod(this.days, this.label);

  DateTime get startDate => DateTime.now().subtract(Duration(days: days));
  DateTime get endDate => DateTime.now();
}

/// Aggregate statistics for a symbol over a period
class SymbolAggregateStats {
  final String symbol;
  final List<EntityStatsEntity> dailyStats;
  final StatsPeriod period;

  const SymbolAggregateStats({
    required this.symbol,
    required this.dailyStats,
    required this.period,
  });

  /// Average sentiment over the period
  double get averageSentiment {
    if (dailyStats.isEmpty) return 0.0;
    final sum = dailyStats.fold<double>(
      0.0,
      (prev, stat) => prev + stat.sentimentAvg,
    );
    return sum / dailyStats.length;
  }

  /// Total articles over the period
  int get totalArticles {
    return dailyStats.fold<int>(
      0,
      (prev, stat) => prev + stat.totalDocuments,
    );
  }

  /// Average daily articles
  double get averageDailyArticles {
    if (dailyStats.isEmpty) return 0.0;
    return totalArticles / dailyStats.length;
  }

  /// Get sentiment trend (positive if trending up)
  double get sentimentTrend {
    if (dailyStats.length < 2) return 0.0;

    // Compare first half average to second half average
    final midpoint = dailyStats.length ~/ 2;
    final firstHalf = dailyStats.sublist(0, midpoint);
    final secondHalf = dailyStats.sublist(midpoint);

    final firstAvg = firstHalf.isEmpty
        ? 0.0
        : firstHalf.fold<double>(0.0, (p, s) => p + s.sentimentAvg) /
            firstHalf.length;
    final secondAvg = secondHalf.isEmpty
        ? 0.0
        : secondHalf.fold<double>(0.0, (p, s) => p + s.sentimentAvg) /
            secondHalf.length;

    return secondAvg - firstAvg;
  }

  /// Get volume trend (positive if trending up)
  double get volumeTrend {
    if (dailyStats.length < 2) return 0.0;

    final midpoint = dailyStats.length ~/ 2;
    final firstHalf = dailyStats.sublist(0, midpoint);
    final secondHalf = dailyStats.sublist(midpoint);

    final firstAvg = firstHalf.isEmpty
        ? 0.0
        : firstHalf.fold<int>(0, (p, s) => p + s.totalDocuments) /
            firstHalf.length;
    final secondAvg = secondHalf.isEmpty
        ? 0.0
        : secondHalf.fold<int>(0, (p, s) => p + s.totalDocuments) /
            secondHalf.length;

    return secondAvg - firstAvg;
  }
}
