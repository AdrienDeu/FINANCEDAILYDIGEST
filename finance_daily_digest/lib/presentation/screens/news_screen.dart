import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../widgets/news_list_item.dart';
import '../widgets/shimmer_loading.dart';

/// Screen showing list of financial news
class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsListProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualités'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: newsAsync.when(
        data: (newsList) {
          if (newsList.isEmpty) {
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
                    'Aucune actualité disponible',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          // Sort by date (most recent first)
          final sortedNews = List.from(newsList)
            ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(newsListProvider(null));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedNews.length,
              itemBuilder: (context, index) {
                final news = sortedNews[index];
                return NewsListItem(news: news);
              },
            ),
          );
        },
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: List.generate(10, (_) => const NewsCardShimmer()),
        ),
        error: (error, stack) {
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
                  onPressed: () {
                    ref.invalidate(newsListProvider(null));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
