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
    final selectedCategory = ref.watch(newsCategoryFilterProvider);
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
          // Category filter chips
          _CategoryFilterChips(
            selectedCategory: selectedCategory,
            onCategorySelected: (category) {
              ref.read(newsCategoryFilterProvider.notifier).state = category;
            },
          ),
          // News list
          Expanded(
            child: newsAsync.when(
              data: (newsList) => _NewsListContent(
                newsList: newsList,
                selectedCategory: selectedCategory,
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

/// Category filter chips widget
class _CategoryFilterChips extends StatelessWidget {
  final NewsCategory selectedCategory;
  final ValueChanged<NewsCategory> onCategorySelected;

  const _CategoryFilterChips({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: NewsCategory.values
              .where((c) => c != NewsCategory.general) // Exclude general, it's not user-facing
              .map((category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_getCategoryLabel(category)),
                      selected: selectedCategory == category,
                      onSelected: (_) => onCategorySelected(category),
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                        color: selectedCategory == category
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: selectedCategory == category
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),)
              .toList(),
        ),
      ),
    );
  }

  String _getCategoryLabel(NewsCategory category) {
    switch (category) {
      case NewsCategory.all:
        return 'Tous';
      case NewsCategory.action:
        return 'Actions';
      case NewsCategory.etf:
        return 'ETF';
      case NewsCategory.obligation:
        return 'Obligations';
      case NewsCategory.general:
        return 'Général';
    }
  }
}

/// News list content widget
class _NewsListContent extends StatelessWidget {
  final List<NewsEntity> newsList;
  final NewsCategory selectedCategory;
  final Future<void> Function() onRefresh;

  const _NewsListContent({
    required this.newsList,
    required this.selectedCategory,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Filter news by category (client-side, instant filtering)
    final filteredNews = _filterNewsByCategory(newsList, selectedCategory);

    // Sort by date (most recent first)
    final sortedNews = List<NewsEntity>.from(filteredNews)
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
              selectedCategory == NewsCategory.all
                  ? 'Aucune actualité disponible'
                  : 'Aucune actualité dans cette catégorie',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
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

  List<NewsEntity> _filterNewsByCategory(
    List<NewsEntity> news,
    NewsCategory category,
  ) {
    if (category == NewsCategory.all) {
      return news;
    }

    return news.where((item) {
      final itemCategory = item.category?.toLowerCase() ?? '';
      switch (category) {
        case NewsCategory.action:
          return itemCategory.contains('action') ||
              itemCategory.contains('stock') ||
              itemCategory.contains('equity');
        case NewsCategory.etf:
          return itemCategory.contains('etf') ||
              itemCategory.contains('tracker') ||
              itemCategory.contains('index');
        case NewsCategory.obligation:
          return itemCategory.contains('obligation') ||
              itemCategory.contains('bond') ||
              itemCategory.contains('fixed');
        case NewsCategory.general:
        case NewsCategory.all:
          return true;
      }
    }).toList();
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
