import 'package:flutter/material.dart';

import '../../domain/entities/news_entity.dart';

/// Card widget for displaying a news item in the digest
class DigestCard extends StatelessWidget {
  final NewsEntity news;

  const DigestCard({
    super.key,
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(news.publishedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to article detail (STORY-009)
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              if (news.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    news.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.article, size: 32),
                      );
                    },
                  ),
                ),
              if (news.imageUrl != null) const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      news.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Description
                    if (news.description != null) ...[
                      Text(
                        news.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Metadata
                    Row(
                      children: [
                        if (news.source != null) ...[
                          Icon(Icons.source, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            news.source!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes}min';
    } else {
      return 'à l\'instant';
    }
  }
}
