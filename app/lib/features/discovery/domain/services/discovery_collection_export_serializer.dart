import 'dart:convert';
import '../entities/discovery.dart';

class DiscoveryCollectionExportSerializer {
  static const String formatIdentifier = 'what-was-that-discoveries';
  static const int currentVersion = 1;

  /// Serializes a list of [Discovery] entities into a formatted, versioned JSON string.
  static String serialize({
    required List<Discovery> discoveries,
    DateTime? exportedAt,
  }) {
    final timestamp = (exportedAt ?? DateTime.now().toUtc()).toUtc().toIso8601String();

    final exportMap = <String, dynamic>{
      'format': formatIdentifier,
      'version': currentVersion,
      'exportedAt': timestamp,
      'discoveries': discoveries.map(_discoveryToJson).toList(),
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(exportMap);
  }

  static Map<String, dynamic> _discoveryToJson(Discovery discovery) {
    return {
      'id': discovery.id,
      'title': discovery.title,
      'explanation': discovery.explanation,
      'confidence': discovery.confidence.name,
      'createdAt': discovery.createdAt.toUtc().toIso8601String(),
      'location': discovery.location != null
          ? {
              'latitude': discovery.location!.latitude,
              'longitude': discovery.location!.longitude,
            }
          : null,
    };
  }
}
