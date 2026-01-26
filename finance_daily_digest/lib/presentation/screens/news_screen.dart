import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/news_entity.dart';
import '../providers/providers.dart';
import '../widgets/news_list_item.dart';
import '../widgets/shimmer_loading.dart';

/// Screen showing list of financial news with category and region filtering
class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsListProvider);
    final selectedIndustry = ref.watch(newsIndustryFilterProvider);
    final selectedRegion = ref.watch(newsRegionFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualités'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Region filter chips
          _RegionFilterChips(
            selectedRegion: selectedRegion,
            onRegionSelected: (region) {
              ref.read(newsRegionFilterProvider.notifier).state = region;
            },
          ),
          // Industry filter chips
          _IndustryFilterChips(
            selectedIndustry: selectedIndustry,
            onIndustrySelected: (industry) {
              ref.read(newsIndustryFilterProvider.notifier).state = industry;
            },
          ),
          // News list
          Expanded(
            child: newsAsync.when(
              data: (newsList) => _NewsListContent(
                newsList: newsList,
                onRefresh: () async {
                  ref.invalidate(newsListProvider);
                },
              ),
              loading: () => ListView(
                padding: const EdgeInsets.all(16),
                children: List.generate(10, (_) => const NewsCardShimmer()),
              ),
              error: (error, stack) => _ErrorContent(
                error: error,
                onRetry: () {
                  ref.invalidate(newsListProvider);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Region filter chips widget
class _RegionFilterChips extends StatelessWidget {
  final NewsRegion selectedRegion;
  final ValueChanged<NewsRegion> onRegionSelected;

  const _RegionFilterChips({
    required this.selectedRegion,
    required this.onRegionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.public, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            ...NewsRegion.values.map((region) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_getRegionLabel(region)),
                avatar: _getRegionIcon(region),
                selected: selectedRegion == region,
                onSelected: (_) => onRegionSelected(region),
                selectedColor: Theme.of(context).colorScheme.secondary,
                labelStyle: TextStyle(
                  color: selectedRegion == region
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: selectedRegion == region
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _getRegionLabel(NewsRegion region) {
    switch (region) {
      case NewsRegion.all:
        return 'Monde';
      case NewsRegion.france:
        return 'France';
      case NewsRegion.europe:
        return 'Europe';
      case NewsRegion.usa:
        return 'USA';
      case NewsRegion.asia:
        return 'Asie';
    }
  }

  Widget? _getRegionIcon(NewsRegion region) {
    switch (region) {
      case NewsRegion.all:
        return null;
      case NewsRegion.france:
        return const Text('🇫🇷', style: TextStyle(fontSize: 14));
      case NewsRegion.europe:
        return const Text('🇪🇺', style: TextStyle(fontSize: 14));
      case NewsRegion.usa:
        return const Text('🇺🇸', style: TextStyle(fontSize: 14));
      case NewsRegion.asia:
        return const Text('🌏', style: TextStyle(fontSize: 14));
    }
  }
}

/// Industry filter chips widget
class _IndustryFilterChips extends StatelessWidget {
  final NewsIndustry selectedIndustry;
  final ValueChanged<NewsIndustry> onIndustrySelected;

  const _IndustryFilterChips({
    required this.selectedIndustry,
    required this.onIndustrySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: NewsIndustry.values
              .map((industry) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_getIndustryLabel(industry)),
                      selected: selectedIndustry == industry,
                      onSelected: (_) => onIndustrySelected(industry),
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: selectedIndustry == industry
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: selectedIndustry == industry
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  String _getIndustryLabel(NewsIndustry industry) {
    switch (industry) {
      case NewsIndustry.all:
        return 'Tous';
      case NewsIndustry.technology:
        return 'Technologie';
      case NewsIndustry.industrials:
        return 'Industrie';
      case NewsIndustry.healthcare:
        return 'Santé';
      case NewsIndustry.financials:
        return 'Finance';
      case NewsIndustry.energy:
        return 'Énergie';
      case NewsIndustry.materials:
        return 'Matériaux';
      case NewsIndustry.telecom:
        return 'Télécom';
      case NewsIndustry.utilities:
        return 'Services publics';
    }
  }
}

/// News list content widget
class _NewsListContent extends StatelessWidget {
  final List<NewsEntity> newsList;
  final Future<void> Function() onRefresh;

  const _NewsListContent({
    required this.newsList,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Sort by date (most recent first)
    final sortedNews = List<NewsEntity>.from(newsList)
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    if (sortedNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune actualité ne correspond à vos filtres',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedNews.length,
        itemBuilder: (context, index) {
          final news = sortedNews[index];
          return NewsListItem(news: news);
        },
      ),
    );
  }
}

/// Error content widget
class _ErrorContent extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorContent({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
