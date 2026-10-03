import 'dart:io';
import 'package:flutter/material.dart';

import '../../domain/entities/identification_result.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final IdentificationResult result;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnidentifiable = !result.identifiable;

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
                  child: File(imagePath).existsSync()
                      ? Image.file(
                          File(imagePath),
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
                result.title,
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
                  result.explanation,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Confidence badge
              if (result.identifiable)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(result.confidence).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getConfidenceColor(result.confidence),
                      ),
                    ),
                    child: Text(
                      'Confidence: ${result.confidence.displayName}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getConfidenceColor(result.confidence),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Try Again Button
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
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