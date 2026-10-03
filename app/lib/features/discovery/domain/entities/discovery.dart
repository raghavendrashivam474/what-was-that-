import 'package:uuid/uuid.dart';
import '../../../identification/domain/entities/identification_result.dart';

class Discovery {
  final String id;
  final IdentificationResult identificationResult;
  final String imagePath;
  final DateTime createdAt;

  const Discovery({
    required this.id,
    required this.identificationResult,
    required this.imagePath,
    required this.createdAt,
  });

  /// Factory helper to create a new Discovery instance with a generated UUID and current timestamp
  factory Discovery.create({
    required IdentificationResult identificationResult,
    required String imagePath,
    String? id,
    DateTime? createdAt,
  }) {
    return Discovery(
      id: id ?? const Uuid().v4(),
      identificationResult: identificationResult,
      imagePath: imagePath,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  // Convenience getters delegating to the wrapped IdentificationResult
  String get title => identificationResult.title;
  String get explanation => identificationResult.explanation;
  IdentificationConfidence get confidence => identificationResult.confidence;
  bool get identifiable => identificationResult.identifiable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Discovery &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          imagePath == other.imagePath &&
          createdAt == other.createdAt &&
          identificationResult.title == other.identificationResult.title &&
          identificationResult.explanation == other.identificationResult.explanation &&
          identificationResult.confidence == other.identificationResult.confidence &&
          identificationResult.identifiable == other.identificationResult.identifiable;

  @override
  int get hashCode =>
      id.hashCode ^
      imagePath.hashCode ^
      createdAt.hashCode ^
      identificationResult.hashCode;
}
