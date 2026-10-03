import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/identification/data/models/identification_result_model.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';

void main() {
  group('IdentificationConfidence', () {
    test('should parse confidence strings correctly', () {
      expect(IdentificationConfidence.fromString('high'), IdentificationConfidence.high);
      expect(IdentificationConfidence.fromString('HIGH'), IdentificationConfidence.high);
      expect(IdentificationConfidence.fromString('medium'), IdentificationConfidence.medium);
      expect(IdentificationConfidence.fromString('low'), IdentificationConfidence.low);
      expect(IdentificationConfidence.fromString('unknown'), IdentificationConfidence.unknown);
      expect(IdentificationConfidence.fromString('invalid_string'), IdentificationConfidence.unknown);
      expect(IdentificationConfidence.fromString(null), IdentificationConfidence.unknown);
    });
  });

  group('IdentificationResultModel', () {
    test('should correctly parse valid JSON', () {
      final json = {
        'identifiable': true,
        'title': 'USB-C Connector',
        'explanation': 'A reversible connector commonly used for charging and data.',
        'confidence': 'high',
      };

      final model = IdentificationResultModel.fromJson(json);

      expect(model.identifiable, true);
      expect(model.title, 'USB-C Connector');
      expect(model.explanation, 'A reversible connector commonly used for charging and data.');
      expect(model.confidence, IdentificationConfidence.high);
    });

    test('should handle unidentifiable responses per Section 16', () {
      final json = {
        'identifiable': false,
        'title': "I don't know",
        'explanation': 'Try taking a clearer photo with better lighting.',
        'confidence': 'unknown',
      };

      final model = IdentificationResultModel.fromJson(json);

      expect(model.identifiable, false);
      expect(model.confidence, IdentificationConfidence.unknown);
      expect(model.explanation, 'Try taking a clearer photo with better lighting.');
    });

    test('should parse raw JSON with markdown fences', () {
      const rawJson = '''```json
{
  "identifiable": true,
  "title": "Monstera Deliciosa",
  "explanation": "A species of flowering plant native to tropical forests.",
  "confidence": "medium"
}
```''';

      final model = IdentificationResultModel.fromRawJson(rawJson);

      expect(model.identifiable, true);
      expect(model.title, 'Monstera Deliciosa');
      expect(model.confidence, IdentificationConfidence.medium);
    });

    test('should fallback gracefully when identifiable is false and fields are empty', () {
      final json = {
        'identifiable': false,
      };

      final model = IdentificationResultModel.fromJson(json);

      expect(model.identifiable, false);
      expect(model.title, "I couldn't identify this confidently.");
      expect(model.confidence, IdentificationConfidence.unknown);
    });
  });
}
