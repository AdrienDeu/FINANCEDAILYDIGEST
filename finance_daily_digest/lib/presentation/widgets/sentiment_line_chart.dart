import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/entity_stats_entity.dart';

/// Line chart widget for displaying sentiment evolution over time
class SentimentLineChart extends StatefulWidget {
  final SymbolAggregateStats stats;
  final String symbol;

  const SentimentLineChart({
    super.key,
    required this.stats,
    required this.symbol,
  });

  @override
  State<SentimentLineChart> createState() => _SentimentLineChartState();
}

class _SentimentLineChartState extends State<SentimentLineChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dailyStats = widget.stats.dailyStats;

    if (dailyStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune donnée disponible',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Sentiment - ${widget.symbol}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildTrendIndicator(theme),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 8),
            child: LineChart(
              _buildLineChartData(theme, dailyStats),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ),
        _buildLegend(theme),
      ],
    );
  }

  Widget _buildTrendIndicator(ThemeData theme) {
    final trend = widget.stats.sentimentTrend;
    final isPositive = trend > 0.05;
    final isNegative = trend < -0.05;

    IconData icon;
    Color color;
    String label;

    if (isPositive) {
      icon = Icons.trending_up;
      color = Colors.green;
      label = 'En hausse';
    } else if (isNegative) {
      icon = Icons.trending_down;
      color = Colors.red;
      label = 'En baisse';
    } else {
      icon = Icons.trending_flat;
      color = Colors.orange;
      label = 'Stable';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }

  LineChartData _buildLineChartData(
    ThemeData theme,
    List<EntityStatsEntity> dailyStats,
  ) {
    final spots = <FlSpot>[];
    final colors = <Color>[];

    for (int i = 0; i < dailyStats.length; i++) {
      final stat = dailyStats[i];
      spots.add(FlSpot(i.toDouble(), stat.sentimentAvg));
      colors.add(_getSentimentColor(stat.sentimentAvg));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 0.2,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 0.5,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(1),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: _getBottomInterval(dailyStats.length),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= dailyStats.length) {
                return const SizedBox.shrink();
              }
              final date = dailyStats[index].date;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  DateFormat('dd/MM').format(date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          left: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      minY: -1,
      maxY: 1,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => theme.colorScheme.surfaceContainerHighest,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index < 0 || index >= dailyStats.length) {
                return null;
              }
              final stat = dailyStats[index];
              final dateStr = DateFormat('dd MMM yyyy', 'fr_FR').format(stat.date);
              return LineTooltipItem(
                '$dateStr\nSentiment: ${stat.sentimentAvg.toStringAsFixed(2)}',
                TextStyle(
                  color: _getSentimentColor(stat.sentimentAvg),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
        touchCallback: (event, response) {
          if (response?.lineBarSpots != null && response!.lineBarSpots!.isNotEmpty) {
            setState(() {
              _touchedIndex = response.lineBarSpots!.first.x.toInt();
            });
          } else {
            setState(() {
              _touchedIndex = null;
            });
          }
        },
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final color = _getSentimentColor(spot.y);
              return FlDotCirclePainter(
                radius: _touchedIndex == index ? 6 : 4,
                color: color,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.3),
                theme.colorScheme.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: 0.2,
            color: Colors.green.withValues(alpha: 0.5),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
          HorizontalLine(
            y: -0.2,
            color: Colors.red.withValues(alpha: 0.5),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
          HorizontalLine(
            y: 0,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ],
      ),
    );
  }

  double _getBottomInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 30) return 5;
    return 10;
  }

  Color _getSentimentColor(double sentiment) {
    if (sentiment > 0.2) return Colors.green;
    if (sentiment < -0.2) return Colors.red;
    return Colors.orange;
  }

  Widget _buildLegend(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Colors.green, 'Positif (>0.2)', theme),
          const SizedBox(width: 16),
          _legendItem(Colors.orange, 'Neutre', theme),
          const SizedBox(width: 16),
          _legendItem(Colors.red, 'Négatif (<-0.2)', theme),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
