import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../features/discovery/domain/entities/discovery.dart';
import '../../../../features/discovery/domain/repositories/discovery_repository.dart';
import '../../../../features/discovery/domain/services/discovery_sharer.dart';
import '../../../../features/discovery/data/services/platform_discovery_sharer.dart';
import '../../../../features/identification/domain/entities/identification_result.dart';
import '../../presentation/screens/discovery_map_screen.dart';

class DiscoveryDetailScreen extends StatelessWidget {
  final Discovery discovery;
  final DiscoveryRepository repository;
  final DiscoverySharer sharer;

  const DiscoveryDetailScreen({
    super.key,
    required this.discovery,
    required this.repository,
    this.sharer = const PlatformDiscoverySharer(),
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

  Future<void> _share(BuildContext context) async {
    try {
      await sharer.share(discovery);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't share this discovery. Please try again."),
          ),
        );
      }
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
    final hasLocation = discovery.location != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discovery Detail'),
        actions: [
          IconButton(
            key: const Key('share_discovery_button'),
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Discovery',
            onPressed: () => _share(context),
          ),
          IconButton(
            key: const Key('delete_discovery_button'),
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
                      : theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
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
                      color: _getConfidenceColor(discovery.confidence)
                          .withValues(alpha: 0.12),
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
              const SizedBox(height: 24),
              // Location Segment (S3-B Spatial Recall)
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Location Context',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (hasLocation) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Saved with coordinates:\nLat: ${discovery.location!.latitude.toStringAsFixed(5)}, Lon: ${discovery.location!.longitude.toStringAsFixed(5)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DiscoveryMapScreen(
                          repository: repository,
                          initialDiscoveryId: discovery.id,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('View on Map'),
                ),
              ] else ...[
                Row(
                  children: [
                    const Icon(
                      Icons.location_off_outlined,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Location context was not captured for this discovery.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
