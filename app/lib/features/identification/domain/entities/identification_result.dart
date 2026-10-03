enum IdentificationConfidence {
  high,
  medium,
  low,
  unknown;

  static IdentificationConfidence fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'high':
        return IdentificationConfidence.high;
      case 'medium':
        return IdentificationConfidence.medium;
      case 'low':
        return IdentificationConfidence.low;
      default:
        return IdentificationConfidence.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case IdentificationConfidence.high:
        return 'High';
      case IdentificationConfidence.medium:
        return 'Medium';
      case IdentificationConfidence.low:
        return 'Low';
      case IdentificationConfidence.unknown:
        return 'Unknown';
    }
  }
}

class IdentificationResult {
  final bool identifiable;
  final String title;
  final String explanation;
  final IdentificationConfidence confidence;

  const IdentificationResult({
    required this.identifiable,
    required this.title,
    required this.explanation,
    required this.confidence,
  });

  factory IdentificationResult.unidentifiable([String? customMessage]) {
    return IdentificationResult(
      identifiable: false,
      title: "I couldn't identify this confidently.",
      explanation: customMessage ??
          'Try taking a clearer photo with the object centered and well lit.',
      confidence: IdentificationConfidence.unknown,
    );
  }
}
