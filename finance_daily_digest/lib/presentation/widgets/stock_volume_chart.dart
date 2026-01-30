import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/stock_chart_entity.dart';

/// Bar chart widget for displaying stock trading volume over time
class StockVolumeChart extends StatefulWidget {
  final StockChartEntity chart;

  const StockVolumeChart({
    super.key,
    required this.chart,
  });

  @override
  State<StockVolumeChart> createState() => _StockVolumeChartState();
}

class _StockVolumeChartState extends State<StockVolumeChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataPoints = widget.chart.dataPoints;

    if (dataPoints.isEmpty) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Volume - ${widget.chart.symbol}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Total: ${_formatVolume(widget.chart.totalVolume)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 8),
            child: BarChart(
              _buildBarChartData(theme, dataPoints),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ),
        _buildSummary(theme),
      ],
    );
  }

  String _formatVolume(int volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(1)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toString();
  }

  BarChartData _buildBarChartData(
    ThemeData theme,
    List<StockDataPointEntity> dataPoints,
  ) {
    final barGroups = <BarChartGroupData>[];
    final maxVolume = dataPoints
        .map((p) => p.volume)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    for (int i = 0; i < dataPoints.length; i++) {
      final point = dataPoints[i];
      final isTouched = _touchedIndex == i;
      final isPositive = point.isPositive;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: point.volume.toDouble(),
              color: isPositive
                  ? Colors.green.withValues(alpha: 0.7)
                  : Colors.red.withValues(alpha: 0.7),
              width: _getBarWidth(dataPoints.length),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(2),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxVolume * 1.1,
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
      maxY: maxVolume * 1.1,
      minY: 0,
      groupsSpace: 2,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxVolume / 4,
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
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  _formatVolume(value.toInt()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontSize: 10,
                  ),
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
              if (index < 0 || index >= dataPoints.length) {
                return const SizedBox.shrink();
              }
              // Only show every nth label based on data length
              final interval = _getBottomInterval(dataPoints.length);
              if (index % interval != 0) {
                return const SizedBox.shrink();
              }
              final date = dataPoints[index].date;
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
            if (index < 0 || index >= dataPoints.length) {
              return null;
            }
            final point = dataPoints[index];
            final dateStr = DateFormat('dd MMM yyyy', 'fr_FR').format(point.date);
            final changeIcon = point.isPositive ? '▲' : '▼';
            return BarTooltipItem(
              '$dateStr\n'
              'Volume: ${_formatVolume(point.volume)}\n'
              '$changeIcon ${point.dailyChangePercent.toStringAsFixed(2)}%',
              TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 11,
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
    if (dataLength <= 7) return 16;
    if (dataLength <= 14) return 10;
    if (dataLength <= 31) return 6;
    if (dataLength <= 90) return 3;
    return 2;
  }

  int _getBottomInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 31) return 5;
    if (dataLength <= 90) return 15;
    return 30;
  }

  Widget _buildSummary(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _summaryItem(
            'Moyenne/jour',
            _formatVolume(widget.chart.averageVolume.toInt()),
            Icons.show_chart,
            theme,
          ),
          _summaryItem(
            'Total période',
            _formatVolume(widget.chart.totalVolume),
            Icons.bar_chart,
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
          size: 14,
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
