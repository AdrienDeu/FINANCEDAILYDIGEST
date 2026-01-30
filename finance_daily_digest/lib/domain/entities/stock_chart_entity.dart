/// Domain entity for stock chart data
class StockChartEntity {
  final String symbol;
  final String currency;
  final String exchangeName;
  final List<StockDataPointEntity> dataPoints;

  const StockChartEntity({
    required this.symbol,
    required this.currency,
    required this.exchangeName,
    required this.dataPoints,
  });

  bool get isEmpty => dataPoints.isEmpty;
  bool get isNotEmpty => dataPoints.isNotEmpty;

  /// Get price change over the period
  double get priceChange {
    if (dataPoints.length < 2) return 0;
    return dataPoints.last.close - dataPoints.first.close;
  }

  /// Get price change percentage
  double get priceChangePercent {
    if (dataPoints.length < 2 || dataPoints.first.close == 0) return 0;
    return (priceChange / dataPoints.first.close) * 100;
  }

  /// Get average volume
  double get averageVolume {
    if (dataPoints.isEmpty) return 0;
    final totalVolume = dataPoints.fold<int>(0, (sum, p) => sum + p.volume);
    return totalVolume / dataPoints.length;
  }

  /// Get total volume
  int get totalVolume {
    return dataPoints.fold<int>(0, (sum, p) => sum + p.volume);
  }

  /// Get highest price in period
  double get highestPrice {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.map((p) => p.high).reduce((a, b) => a > b ? a : b);
  }

  /// Get lowest price in period
  double get lowestPrice {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.map((p) => p.low).reduce((a, b) => a < b ? a : b);
  }

  /// Get latest closing price
  double get latestPrice {
    if (dataPoints.isEmpty) return 0;
    return dataPoints.last.close;
  }

  /// Is the stock trending up?
  bool get isTrendingUp => priceChangePercent > 0;

  /// Get trend label in French
  String get trendLabel {
    if (priceChangePercent > 2) return 'En forte hausse';
    if (priceChangePercent > 0) return 'En hausse';
    if (priceChangePercent < -2) return 'En forte baisse';
    if (priceChangePercent < 0) return 'En baisse';
    return 'Stable';
  }
}

/// Individual stock data point entity
class StockDataPointEntity {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double adjustedClose;
  final int volume;

  const StockDataPointEntity({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.adjustedClose,
    required this.volume,
  });

  /// Get the daily price change
  double get dailyChange => close - open;

  /// Get the daily price change percentage
  double get dailyChangePercent => open != 0 ? (dailyChange / open) * 100 : 0;

  /// Is this a positive day (close > open)?
  bool get isPositive => close >= open;
}

/// Chart period enum
enum ChartPeriod {
  sevenDays('7d', '7j'),
  oneMonth('1mo', '1M'),
  threeMonths('3mo', '3M'),
  sixMonths('6mo', '6M'),
  oneYear('1y', '1A');

  final String apiValue;
  final String label;

  const ChartPeriod(this.apiValue, this.label);
}
