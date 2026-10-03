import 'dart:io';
import 'package:flutter/material.dart';
import 'package:what_was_that/features/discovery/data/services/platform_discovery_exporter.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:what_was_that/features/discovery/domain/services/discovery_exporter.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';
import 'package:what_was_that/features/identification/domain/repositories/image_identifier.dart';
import 'package:what_was_that/features/identification/presentation/screens/camera_screen.dart';
import 'package:what_was_that/features/discovery/presentation/screens/discovery_detail_screen.dart';
import 'package:what_was_that/features/discovery/presentation/screens/discovery_map_screen.dart';

class DiscoveryListScreen extends StatefulWidget {
  final DiscoveryRepository repository;
  final ImageIdentifier identifier;
  final DiscoveryExporter exporter;

  const DiscoveryListScreen({
    super.key,
    required this.repository,
    required this.identifier,
    this.exporter = const PlatformDiscoveryExporter(),
  });

  @override
  State<DiscoveryListScreen> createState() => _DiscoveryListScreenState();
}

class _DiscoveryListScreenState extends State<DiscoveryListScreen> {
  List<Discovery> _allDiscoveries = [];
  List<Discovery> _filteredDiscoveries = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadDiscoveries();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilter();
    });
  }

  void _applyFilter() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredDiscoveries = List.from(_allDiscoveries);
    } else {
      _filteredDiscoveries = _allDiscoveries.where((d) {
        return d.title.toLowerCase().contains(query) ||
            d.explanation.toLowerCase().contains(query);
      }).toList();
    }
  }

  Future<void> _loadDiscoveries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final discoveries = await widget.repository.getAll();
      setState(() {
        _allDiscoveries = discoveries;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _exportDiscoveries() async {
    if (_allDiscoveries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No discoveries to export yet.'),
        ),
      );
      return;
    }

    try {
      await widget.exporter.export(_allDiscoveries);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't export discoveries. Please try again."),
          ),
        );
      }
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  String _sectionLabel(DateTime date) {
    if (_isToday(date)) return 'Today';
    if (_isYesterday(date)) return 'Yesterday';

    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _cardTimestamp(DateTime date) {
    final section = _sectionLabel(date);
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$section \u00b7 $hour:$minute $period';
  }

  Color _confidenceColor(IdentificationConfidence confidence) {
    switch (confidence) {
      case IdentificationConfidence.high:
        return Colors.green.shade700;
      case IdentificationConfidence.medium:
        return Colors.orange.shade700;
      case IdentificationConfidence.low:
        return Colors.amber.shade800;
      case IdentificationConfidence.unknown:
        return Colors.grey.shade600;
    }
  }

  List<Widget> _buildGroupedItems(BuildContext context) {
    final theme = Theme.of(context);
    final items = <Widget>[];
    String? currentSection;

    for (final discovery in _filteredDiscoveries) {
      final section = _sectionLabel(discovery.createdAt);
      if (section != currentSection) {
        currentSection = section;
        items.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
            child: Text(
              section,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        );
      }
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildDiscoveryCard(context, discovery),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSearching = _searchQuery.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Discoveries'),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('export_discoveries_button'),
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: 'Export Discoveries',
            onPressed: _exportDiscoveries,
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Discovery Map',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DiscoveryMapScreen(
                    repository: widget.repository,
                  ),
                ),
              ).then((_) => _loadDiscoveries());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              key: const Key('search_field'),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search discoveries...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _filteredDiscoveries.isEmpty
                        ? isSearching
                            ? _buildNoResultsState()
                            : _buildEmptyState(context)
                        : ListView(
                            key: const Key('discovery_list'),
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            children: _buildGroupedItems(context),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
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
              'No discoveries yet',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Capture something you don't recognize\nand it will appear here.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

  Widget _buildNoResultsState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nothing found',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryCard(BuildContext context, Discovery discovery) {
    final theme = Theme.of(context);
    final confColor = _confidenceColor(discovery.confidence);

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
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${discovery.confidence.displayName} confidence',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: confColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _cardTimestamp(discovery.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
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
