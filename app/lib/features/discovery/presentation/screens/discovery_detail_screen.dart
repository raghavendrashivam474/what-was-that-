import 'dart:io';
import 'package:flutter/material.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';

class DiscoveryDetailScreen extends StatelessWidget {
  final Discovery discovery;
  final DiscoveryRepository repository;

  const DiscoveryDetailScreen({
    super.key,
    required this.discovery,
    required this.repository,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    return '$month $day, $year';
  }

  Color _getConfidenceColor(IdentificationConfidence confidence) {
    switch (confidence) {
      case IdentificationConfidence.high:
        return Colors.green.shade700;
      case IdentificationConfidence.medium:
        return Colors.orange.shade700;
      case IdentificationConfidence.low:
        return Colors.amber.shade800;
      case IdentificationConfidence.unknown:
        return Colors.grey.shade700;
    }
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this discovery?'),
        content: const Text(
          'This will permanently delete this saved discovery and its image.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await repository.delete(discovery.id);
        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Couldn't delete this discovery. Please try again."),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnidentifiable = !discovery.identifiable;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discovery Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Discovery',
            onPressed: () => _confirmAndDelete(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 260,
                  color: Colors.black12,
                  child: File(discovery.imagePath).existsSync()
                      ? Image.file(
                          File(discovery.imagePath),
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(Icons.image_not_supported, size: 48),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // Date stamp
              Text(
                'Discovered on ${_formatDate(discovery.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                discovery.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isUnidentifiable ? Colors.orange.shade900 : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Explanation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUnidentifiable
                      ? Colors.orange.shade50
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnidentifiable
                        ? Colors.orange.shade200
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  discovery.explanation,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              // Confidence Badge
              if (discovery.identifiable)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(discovery.confidence).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getConfidenceColor(discovery.confidence),
                      ),
                    ),
                    child: Text(
                      'Confidence: ${discovery.confidence.displayName}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getConfidenceColor(discovery.confidence),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
