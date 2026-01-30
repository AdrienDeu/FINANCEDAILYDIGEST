import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/entity_stats_entity.dart';

/// Bar chart widget for displaying article volume over time
class VolumeBarChart extends StatefulWidget {
  final SymbolAggregateStats stats;
  final String symbol;

  const VolumeBarChart({
    super.key,
    required this.stats,
    required this.symbol,
  });

  @override
  State<VolumeBarChart> createState() => _VolumeBarChartState();
}

class _VolumeBarChartState extends State<VolumeBarChart> {
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
              Icons.bar_chart,
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

    final maxVolume = dailyStats.fold<int>(
      0,
      (max, stat) => stat.totalDocuments > max ? stat.totalDocuments : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Volume - ${widget.symbol}',
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
            child: BarChart(
              _buildBarChartData(theme, dailyStats, maxVolume),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ),
        _buildSummary(theme),
      ],
    );
  }

  Widget _buildTrendIndicator(ThemeData theme) {
    final trend = widget.stats.volumeTrend;
    final isPositive = trend > 1;
    final isNegative = trend < -1;

    IconData icon;
    Color color;
    String label;

    if (isPositive) {
      icon = Icons.trending_up;
      color = Colors.blue;
      label = 'En hausse';
    } else if (isNegative) {
      icon = Icons.trending_down;
      color = Colors.grey;
      label = 'En baisse';
    } else {
      icon = Icons.trending_flat;
      color = Colors.blueGrey;
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

  BarChartData _buildBarChartData(
    ThemeData theme,
    List<EntityStatsEntity> dailyStats,
    int maxVolume,
  ) {
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < dailyStats.length; i++) {
      final stat = dailyStats[i];
      final isTouched = _touchedIndex == i;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: stat.totalDocuments.toDouble(),
              color: _getVolumeColor(stat.totalDocuments, maxVolume, theme),
              width: _getBarWidth(dailyStats.length),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxVolume.toDouble() * 1.1,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
            ),
          ],
          showingTooltipIndicators: isTouched ? [0] : [],
        ),
      );
    }

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxVolume.toDouble() * 1.1,
      minY: 0,
      groupsSpace: 4,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _getHorizontalInterval(maxVolume),
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
            reservedSize: 42,
            interval: _getHorizontalInterval(maxVolume),
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
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
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= dailyStats.length) {
                return const SizedBox.shrink();
              }
              // Only show every nth label based on data length
              final interval = _getBottomInterval(dailyStats.length);
              if (index % interval != 0) {
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
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => theme.colorScheme.surfaceContainerHighest,
          tooltipRoundedRadius: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final index = group.x;
            if (index < 0 || index >= dailyStats.length) {
              return null;
            }
            final stat = dailyStats[index];
            final dateStr = DateFormat('dd MMM yyyy', 'fr_FR').format(stat.date);
            return BarTooltipItem(
              '$dateStr\n${stat.totalDocuments} articles',
              TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
        ),
        touchCallback: (event, response) {
          if (response?.spot != null) {
            setState(() {
              _touchedIndex = response!.spot!.touchedBarGroupIndex;
            });
          } else {
            setState(() {
              _touchedIndex = null;
            });
          }
        },
      ),
      barGroups: barGroups,
    );
  }

  double _getBarWidth(int dataLength) {
    if (dataLength <= 7) return 20;
    if (dataLength <= 14) return 12;
    if (dataLength <= 30) return 8;
    return 4;
  }

  int _getBottomInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 30) return 5;
    return 10;
  }

  double _getHorizontalInterval(int maxVolume) {
    if (maxVolume <= 10) return 2;
    if (maxVolume <= 50) return 10;
    if (maxVolume <= 100) return 20;
    return 50;
  }

  Color _getVolumeColor(int volume, int maxVolume, ThemeData theme) {
    final ratio = volume / maxVolume;
    if (ratio > 0.7) return theme.colorScheme.primary;
    if (ratio > 0.4) return theme.colorScheme.secondary;
    return theme.colorScheme.tertiary;
  }

  Widget _buildSummary(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _summaryItem(
            'Total',
            widget.stats.totalArticles.toString(),
            Icons.article,
            theme,
          ),
          _summaryItem(
            'Moyenne/jour',
            widget.stats.averageDailyArticles.toStringAsFixed(1),
            Icons.show_chart,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
