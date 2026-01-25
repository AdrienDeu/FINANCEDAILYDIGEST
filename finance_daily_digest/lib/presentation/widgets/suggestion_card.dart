import 'package:flutter/material.dart';

import '../../domain/entities/news_entity.dart';
import '../../domain/entities/suggestion_entity.dart';
import '../screens/article_detail_screen.dart';

/// Card widget for displaying an investment suggestion with expandable reasoning
class SuggestionCard extends StatefulWidget {
  final SuggestionEntity suggestion;
  final NewsEntity? relatedNews;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    this.relatedNews,
  });

  @override
  State<SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<SuggestionCard> {
  bool _isExpanded = false;

  // Max lines to show when collapsed
  static const int _collapsedMaxLines = 2;
  // Threshold for showing expand/collapse (approx characters for 2 lines)
  static const int _expandThreshold = 100;

  bool get _shouldShowExpander => widget.suggestion.reasoning.length > _expandThreshold;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with ticker and badges
            Row(
              children: [
                // Ticker + PEA badge group (flexible to avoid overflow)
                Expanded(
                  child: Row(
                    children: [
                      // Ticker
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.suggestion.ticker,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      // PEA badge
                      if (widget.suggestion.peaEligible) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Éligible PEA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Risk badge (fixed size on the right)
                _buildRiskBadge(context),
              ],
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              widget.suggestion.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),

            // Type
            Text(
              widget.suggestion.type,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Reasoning section with "Pourquoi?" header
            _buildReasoningSection(context),

            // Link to related news article
            if (widget.relatedNews != null || widget.suggestion.relatedNewsId != null)
              _buildRelatedNewsLink(context),
          ],
        ),
      ),
    );
  }

  /// Build the reasoning section with expand/collapse functionality
  Widget _buildReasoningSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Pourquoi?" header
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Pourquoi cette suggestion ?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Reasoning text with expand/collapse
        AnimatedCrossFade(
          firstChild: Text(
            widget.suggestion.reasoning,
            maxLines: _collapsedMaxLines,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  height: 1.4,
                ),
          ),
          secondChild: Text(
            widget.suggestion.reasoning,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  height: 1.4,
                ),
          ),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),

        // Expand/collapse button
        if (_shouldShowExpander) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded ? 'Voir moins' : 'Voir plus',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build link to related news article
  Widget _buildRelatedNewsLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: InkWell(
        onTap: () => _navigateToRelatedNews(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.article_outlined,
                size: 16,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.relatedNews?.title ?? 'Voir l\'actualité liée',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.blue[700],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRelatedNews(BuildContext context) {
    if (widget.relatedNews != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ArticleDetailScreen(news: widget.relatedNews!),
        ),
      );
    }
    // If we only have relatedNewsId but no news object, we could fetch it
    // For now, we show a snackbar indicating the feature
    else if (widget.suggestion.relatedNewsId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chargement de l\'article...'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildRiskBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (widget.suggestion.risk.toLowerCase()) {
      case 'faible':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'élevé':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default: // moyen
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            'Risque ${widget.suggestion.risk}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
