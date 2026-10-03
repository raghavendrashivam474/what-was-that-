import 'dart:io';
import 'package:flutter/material.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:what_was_that/features/identification/domain/repositories/image_identifier.dart';
import 'package:what_was_that/features/identification/presentation/screens/camera_screen.dart';
import 'package:what_was_that/features/discovery/presentation/screens/discovery_detail_screen.dart';

class DiscoveryListScreen extends StatefulWidget {
  final DiscoveryRepository repository;
  final ImageIdentifier identifier;

  const DiscoveryListScreen({
    super.key,
    required this.repository,
    required this.identifier,
  });

  @override
  State<DiscoveryListScreen> createState() => _DiscoveryListScreenState();
}

class _DiscoveryListScreenState extends State<DiscoveryListScreen> {
  late Future<List<Discovery>> _discoveriesFuture;

  @override
  void initState() {
    super.initState();
    _loadDiscoveries();
  }

  void _loadDiscoveries() {
    setState(() {
      _discoveriesFuture = widget.repository.getAll();
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Discoveries'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Discovery>>(
        future: _discoveriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load discoveries.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadDiscoveries,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final discoveries = snapshot.data ?? [];

          if (discoveries.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: discoveries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final discovery = discoveries[index];
              return _buildDiscoveryCard(context, discovery);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Nothing here yet.',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The next time you discover\nsomething unfamiliar, save it here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(
                      identifier: widget.identifier,
                      repository: widget.repository,
                    ),
                  ),
                ).then((_) => _loadDiscoveries());
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('What is this?'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryCard(BuildContext context, Discovery discovery) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => DiscoveryDetailScreen(
                discovery: discovery,
                repository: widget.repository,
              ),
            ),
          );
          if (result == true) {
            _loadDiscoveries();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 64,
                  height: 64,
                  color: Colors.black12,
                  child: File(discovery.imagePath).existsSync()
                      ? Image.file(
                          File(discovery.imagePath),
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      discovery.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(discovery.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
