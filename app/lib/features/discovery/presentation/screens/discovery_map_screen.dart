import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/discovery.dart';
import '../../domain/repositories/discovery_repository.dart';
import 'discovery_detail_screen.dart';

class DiscoveryMapScreen extends StatefulWidget {
  final DiscoveryRepository repository;
  final String? initialDiscoveryId;
  final TileProvider? tileProvider;
  final bool enableTileLayer;

  const DiscoveryMapScreen({
    super.key,
    required this.repository,
    this.initialDiscoveryId,
    this.tileProvider,
    this.enableTileLayer = true,
  });

  @override
  State<DiscoveryMapScreen> createState() => _DiscoveryMapScreenState();
}

class _DiscoveryMapScreenState extends State<DiscoveryMapScreen> {
  final MapController _mapController = MapController();
  List<Discovery> _locatedDiscoveries = [];
  Discovery? _selectedDiscovery;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDiscoveries();
  }

  Future<void> _loadDiscoveries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final all = await widget.repository.getAll();
      final located = all.where((d) => d.location != null).toList();

      setState(() {
        _locatedDiscoveries = located;
        _isLoading = false;

        if (widget.initialDiscoveryId != null) {
          final found = located.where((d) => d.id == widget.initialDiscoveryId);
          if (found.isNotEmpty) {
            _selectedDiscovery = found.first;
          }
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  LatLng _getInitialCenter() {
    if (_selectedDiscovery != null && _selectedDiscovery!.location != null) {
      return LatLng(
        _selectedDiscovery!.location!.latitude,
        _selectedDiscovery!.location!.longitude,
      );
    }
    if (_locatedDiscoveries.isNotEmpty) {
      return LatLng(
        _locatedDiscoveries.first.location!.latitude,
        _locatedDiscoveries.first.location!.longitude,
      );
    }
    return const LatLng(0, 0);
  }

  double _getInitialZoom() {
    if (_locatedDiscoveries.isEmpty) return 2.0;
    return 13.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discovery Map'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _locatedDiscoveries.isEmpty
                  ? _buildEmptyState(context)
                  : Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _getInitialCenter(),
                            initialZoom: _getInitialZoom(),
                            onTap: (_, __) {
                              if (_selectedDiscovery != null) {
                                setState(() {
                                  _selectedDiscovery = null;
                                });
                              }
                            },
                          ),
                          children: [
                            if (widget.enableTileLayer)
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.what_was_that',
                                tileProvider: widget.tileProvider,
                              ),
                            MarkerLayer(
                              markers: _locatedDiscoveries.map((discovery) {
                                final isSelected =
                                    _selectedDiscovery?.id == discovery.id;
                                return Marker(
                                  point: LatLng(
                                    discovery.location!.latitude,
                                    discovery.location!.longitude,
                                  ),
                                  width: 48,
                                  height: 48,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDiscovery = discovery;
                                      });
                                    },
                                    child: Icon(
                                      Icons.location_on,
                                      size: isSelected ? 44 : 36,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : Colors.redAccent.shade700,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),

                        // Floating Discovery Preview Card when marker selected
                        if (_selectedDiscovery != null)
                          Positioned(
                            bottom: 24,
                            left: 16,
                            right: 16,
                            child: _buildPreviewCard(
                                context, _selectedDiscovery!),
                          ),
                      ],
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
              Icons.map_outlined,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No mapped discoveries yet',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Discoveries saved with location will appear on this map.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
              'Failed to load mapped discoveries.',
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

  Widget _buildPreviewCard(BuildContext context, Discovery discovery) {
    final theme = Theme.of(context);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 56,
                  height: 56,
                  color: Colors.black12,
                  child: File(discovery.imagePath).existsSync()
                      ? Image.file(
                          File(discovery.imagePath),
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                      '${discovery.confidence.displayName} confidence',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
