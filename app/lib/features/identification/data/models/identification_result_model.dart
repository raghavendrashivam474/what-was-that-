import 'dart:convert';
import '../../domain/entities/identification_result.dart';

class IdentificationResultModel extends IdentificationResult {
  const IdentificationResultModel({
    required super.identifiable,
    required super.title,
    required super.explanation,
    required super.confidence,
  });

  factory IdentificationResultModel.fromJson(Map<String, dynamic> json) {
    final identifiable = json['identifiable'] == true;
    final title = (json['title'] as String?)?.trim() ?? 'Unknown';
    final explanation = (json['explanation'] as String?)?.trim() ?? '';
    final confidence = IdentificationConfidence.fromString(
      json['confidence'] as String?,
    );

    if (!identifiable) {
      return IdentificationResultModel(
        identifiable: false,
        title: title.isNotEmpty && title != 'Unknown'
            ? title
            : "I couldn't identify this confidently.",
        explanation: explanation.isNotEmpty
            ? explanation
            : 'Try taking a clearer photo with the object centered and well lit.',
        confidence: IdentificationConfidence.unknown,
      );
    }

    return IdentificationResultModel(
      identifiable: true,
      title: title,
      explanation: explanation,
      confidence: confidence,
    );
  }

  factory IdentificationResultModel.fromRawJson(String rawJson) {
    String cleanJson = rawJson.trim();
    if (cleanJson.startsWith('```json')) {
      cleanJson = cleanJson.substring(7);
    } else if (cleanJson.startsWith('```')) {
      cleanJson = cleanJson.substring(3);
    }
    if (cleanJson.endsWith('```')) {
      cleanJson = cleanJson.substring(0, cleanJson.length - 3);
    }
    cleanJson = cleanJson.trim();

    final decoded = json.decode(cleanJson) as Map<String, dynamic>;
    return IdentificationResultModel.fromJson(decoded);
  }
}
