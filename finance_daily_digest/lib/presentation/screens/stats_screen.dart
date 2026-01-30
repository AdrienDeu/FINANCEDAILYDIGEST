import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/stock_chart_entity.dart';
import '../providers/providers.dart';
import '../widgets/price_line_chart.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/stock_volume_chart.dart';

/// Statistics screen displaying stock price and volume charts
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final chartAsync = ref.watch(stockChartProvider);
    final selectedSymbols = ref.watch(selectedStatsSymbolsProvider);
    final period = ref.watch(chartPeriodProvider);
    final viewMode = ref.watch(chartViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(stockChartProvider);
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(stockChartProvider);
          await ref.read(stockChartProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period selector
              _buildPeriodSelector(context, ref, period),

              const Divider(height: 1),

              // Symbol selector
              _buildSymbolSelector(context, ref, selectedSymbols),

              const Divider(height: 1),

              // View mode toggle
              _buildViewModeToggle(context, ref, viewMode),

              const SizedBox(height: 8),

              // Charts
              chartAsync.when(
                data: (charts) {
                  if (charts.isEmpty) {
                    return _buildEmptyState(theme);
                  }
                  return _buildCharts(context, charts, selectedSymbols, viewMode);
                },
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(theme, error, ref),
              ),

              // Summary section
              if (chartAsync.hasValue && chartAsync.value!.isNotEmpty)
                _buildSummarySection(context, chartAsync.value!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    WidgetRef ref,
    ChartPeriod selectedPeriod,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            'Période:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ChartPeriod.values.map((period) {
                  final isSelected = period == selectedPeriod;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(period.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(chartPeriodProvider.notifier).state = period;
                        }
                      },
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolSelector(
    BuildContext context,
    WidgetRef ref,
    List<String> selectedSymbols,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Symboles:',
                style: theme.textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showSymbolPicker(context, ref, selectedSymbols),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Modifier'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedSymbols.map((symbol) {
              return Chip(
                label: Text(symbol),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: selectedSymbols.length > 1
                    ? () {
                        final newList = List<String>.from(selectedSymbols)
                          ..remove(symbol);
                        ref.read(selectedStatsSymbolsProvider.notifier).state =
                            newList;
                      }
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showSymbolPicker(
    BuildContext context,
    WidgetRef ref,
    List<String> currentSelection,
  ) {
    final tempSelection = List<String>.from(currentSelection);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.8,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            'Sélectionner les symboles',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(selectedStatsSymbolsProvider.notifier)
                                  .state = tempSelection;
                              Navigator.pop(context);
                            },
                            child: const Text('Appliquer'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: availableStatsSymbols.length,
                        itemBuilder: (context, index) {
                          final symbol = availableStatsSymbols[index];
                          final isSelected = tempSelection.contains(symbol);

                          return CheckboxListTile(
                            title: Text(symbol),
                            subtitle: Text(_getSymbolDescription(symbol)),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  tempSelection.add(symbol);
                                } else if (tempSelection.length > 1) {
                                  tempSelection.remove(symbol);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  String _getSymbolDescription(String symbol) {
    const descriptions = {
      'AAPL': 'Apple Inc.',
      'MSFT': 'Microsoft Corporation',
      'GOOGL': 'Alphabet Inc.',
      'AMZN': 'Amazon.com Inc.',
      'NVDA': 'NVIDIA Corporation',
      'META': 'Meta Platforms Inc.',
      'TSLA': 'Tesla Inc.',
      'MC.PA': 'LVMH (Euronext Paris)',
      'SAP.DE': 'SAP SE (Xetra)',
    };
    return descriptions[symbol] ?? symbol;
  }

  Widget _buildViewModeToggle(
    BuildContext context,
    WidgetRef ref,
    ChartViewMode viewMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<ChartViewMode>(
        segments: const [
          ButtonSegment(
            value: ChartViewMode.price,
            label: Text('Prix'),
            icon: Icon(Icons.show_chart),
          ),
          ButtonSegment(
            value: ChartViewMode.volume,
            label: Text('Volume'),
            icon: Icon(Icons.bar_chart),
          ),
        ],
        selected: {viewMode},
        onSelectionChanged: (selection) {
          ref.read(chartViewModeProvider.notifier).state = selection.first;
        },
      ),
    );
  }

  Widget _buildCharts(
    BuildContext context,
    Map<String, StockChartEntity> charts,
    List<String> selectedSymbols,
    ChartViewMode viewMode,
  ) {
    final chartWidgets = <Widget>[];

    for (final symbol in selectedSymbols) {
      final chart = charts[symbol];
      if (chart == null || chart.isEmpty) continue;

      chartWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Card(
            child: SizedBox(
              height: 320,
              child: viewMode == ChartViewMode.price
                  ? PriceLineChart(chart: chart)
                  : StockVolumeChart(chart: chart),
            ),
          ),
        ),
      );
    }

    if (chartWidgets.isEmpty) {
      return _buildEmptyState(Theme.of(context));
    }

    return Column(children: chartWidgets);
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          ShimmerLoading(height: 320),
          SizedBox(height: 16),
          ShimmerLoading(height: 320),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée disponible',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez des symboles et une période pour afficher les statistiques.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, Object error, WidgetRef ref) {
    String errorMessage = 'Une erreur est survenue';

    if (error.toString().contains('404')) {
      errorMessage = 'Un ou plusieurs symboles n\'ont pas été trouvés.';
    } else if (error.toString().contains('network') ||
        error.toString().contains('connexion')) {
      errorMessage = 'Erreur de connexion. Vérifiez votre réseau.';
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref.invalidate(stockChartProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    Map<String, StockChartEntity> charts,
  ) {
    final theme = Theme.of(context);

    // Calculate overall performance
    int positiveCount = 0;
    int negativeCount = 0;
    double totalChangePercent = 0;

    for (final chart in charts.values) {
      if (chart.isNotEmpty) {
        if (chart.priceChangePercent > 0) {
          positiveCount++;
        } else {
          negativeCount++;
        }
        totalChangePercent += chart.priceChangePercent;
      }
    }

    final avgChange = charts.isNotEmpty ? totalChangePercent / charts.length : 0.0;
    final isOverallPositive = avgChange >= 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Résumé',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      theme,
                      'Performance moyenne',
                      '${avgChange >= 0 ? '+' : ''}${avgChange.toStringAsFixed(2)}%',
                      isOverallPositive ? Icons.trending_up : Icons.trending_down,
                      isOverallPositive ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      theme,
                      'Tendances',
                      '▲$positiveCount  ▼$negativeCount',
                      Icons.analytics,
                      theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
