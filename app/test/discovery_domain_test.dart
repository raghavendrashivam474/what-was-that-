import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';

void main() {
  group('Discovery Entity Tests', () {
    const mockResult = IdentificationResult(
      identifiable: true,
      title: 'USB-C Cable',
      explanation: 'A standard reversible connector for data and power.',
      confidence: IdentificationConfidence.high,
    );

    test('should properly wrap IdentificationResult and delegate getters', () {
      final now = DateTime.now();
      final discovery = Discovery(
        id: 'test-uuid-1234',
        identificationResult: mockResult,
        imagePath: '/path/to/stored_image.jpg',
        createdAt: now,
      );

      expect(discovery.id, 'test-uuid-1234');
      expect(discovery.imagePath, '/path/to/stored_image.jpg');
      expect(discovery.createdAt, now);
      expect(discovery.title, 'USB-C Cable');
      expect(discovery.explanation, 'A standard reversible connector for data and power.');
      expect(discovery.confidence, IdentificationConfidence.high);
      expect(discovery.identifiable, isTrue);
    });

    test('Discovery.create should generate a valid UUID and timestamp if omitted', () {
      final discovery = Discovery.create(
        identificationResult: mockResult,
        imagePath: '/path/to/stored_image.jpg',
      );

      expect(discovery.id, isNotEmpty);
      expect(discovery.createdAt, isNotNull);
      expect(discovery.title, 'USB-C Cable');
    });

    test('equality checks work as expected', () {
      final now = DateTime(2026, 10, 3, 12, 0, 0);
      final d1 = Discovery(
        id: '1',
        identificationResult: mockResult,
        imagePath: '/a.jpg',
        createdAt: now,
      );
      final d2 = Discovery(
        id: '1',
        identificationResult: mockResult,
        imagePath: '/a.jpg',
        createdAt: now,
      );

      expect(d1, equals(d2));
    });
  });
}
