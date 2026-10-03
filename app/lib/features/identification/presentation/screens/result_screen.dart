import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../../discovery/data/datasources/image_storage_service.dart';
import '../../../discovery/data/providers/geolocator_location_provider.dart';
import '../../../discovery/domain/entities/discovery.dart';
import '../../../discovery/domain/entities/discovery_location.dart';
import '../../../discovery/domain/providers/location_provider.dart';
import '../../../discovery/domain/repositories/discovery_repository.dart';
import '../../domain/entities/identification_result.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final IdentificationResult result;
  final DiscoveryRepository? repository;
  final ImageStorageService? imageStorageService;
  final LocationProvider? locationProvider;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
    this.repository,
    this.imageStorageService,
    this.locationProvider,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaving = false;
  bool _isSaved = false;

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

  Future<void> _saveDiscovery() async {
    if (_isSaving || _isSaved || widget.repository == null) return;

    setState(() {
      _isSaving = true;
    });

    String? persistedImagePath;
    try {
      // 1. Attempt location capture (non-blocking fallback)
      DiscoveryLocation? location;
      if (widget.locationProvider != null) {
        try {
          location = await widget.locationProvider!.getCurrentLocation();
        } catch (_) {
          location = null;
        }
      } else {
        try {
          const provider = GeolocatorLocationProvider();
          location = await provider.getCurrentLocation();
        } catch (_) {
          location = null;
        }
      }

      // 2. Persist image permanently
      final storageService =
          widget.imageStorageService ?? LocalImageStorageService();
      persistedImagePath =
          await storageService.saveImagePermanently(widget.imagePath);

      // 3. Create Discovery with optional location
      final discovery = Discovery.create(
        identificationResult: widget.result,
        imagePath: persistedImagePath,
        location: location,
      );

      // 4. Save to repository
      await widget.repository!.save(discovery);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _isSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('? Saved to your discoveries'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // If db save failed after copying image, cleanup to prevent orphaned file
      if (persistedImagePath != null) {
        final storageService =
            widget.imageStorageService ?? LocalImageStorageService();
        await storageService.deleteImage(persistedImagePath);
      }

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      final errorMessage = e is Failure
          ? e.message
          : "Couldn't save this discovery. Please try again.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnidentifiable = !widget.result.identifiable;

    return Scaffold(
      appBar: AppBar(
        title: const Text('What Was That?'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Captured image card
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 260,
                  color: Colors.black12,
                  child: File(widget.imagePath).existsSync()
                      ? Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(Icons.image_not_supported, size: 48),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Title / Identification name
              Text(
                widget.result.title,
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
                  widget.result.explanation,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Confidence badge
              if (widget.result.identifiable)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(widget.result.confidence)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getConfidenceColor(widget.result.confidence),
                      ),
                    ),
                    child: Text(
                      'Confidence: ${widget.result.confidence.displayName}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getConfidenceColor(widget.result.confidence),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Save Discovery Button (if repository provided)
              if (widget.repository != null) ...[
                if (_isSaved)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Saved to your discoveries',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveDiscovery,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.bookmark_add_outlined),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Save Discovery',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
              ],

              // Try Again Button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
