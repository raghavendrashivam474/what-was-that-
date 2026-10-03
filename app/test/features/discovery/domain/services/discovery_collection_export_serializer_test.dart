import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery_location.dart';
import 'package:what_was_that/features/discovery/domain/services/discovery_collection_export_serializer.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';

void main() {
  group('DiscoveryCollectionExportSerializer Tests', () {
    final fixedExportDate = DateTime.utc(2026, 10, 3, 18, 42, 0);

    test('Serializes an empty collection with valid schema and empty discoveries array', () {
      final jsonString = DiscoveryCollectionExportSerializer.serialize(
        discoveries: [],
        exportedAt: fixedExportDate,
      );

      final Map<String, dynamic> parsed = jsonDecode(jsonString);
      expect(parsed['format'], equals('what-was-that-discoveries'));
      expect(parsed['version'], equals(1));
      expect(parsed['exportedAt'], equals('2026-10-03T18:42:00.000Z'));
      expect(parsed['discoveries'], isEmpty);
    });

    test('Serializes single discovery with location correctly', () {
      final discovery = Discovery.create(
        id: 'uuid-1',
        createdAt: DateTime.utc(2026, 10, 3, 15, 12, 0),
        imagePath: '/path/to/img.jpg',
        location: const DiscoveryLocation(latitude: 28.6139, longitude: 77.2090),
        identificationResult: const IdentificationResult(
          title: 'Coffee Grinder',
          explanation: 'Used to grind coffee beans.',
          confidence: IdentificationConfidence.high,
          identifiable: true,
        ),
      );

      final jsonString = DiscoveryCollectionExportSerializer.serialize(
        discoveries: [discovery],
        exportedAt: fixedExportDate,
      );

      final Map<String, dynamic> parsed = jsonDecode(jsonString);
      final list = parsed['discoveries'] as List;
      expect(list.length, equals(1));

      final first = list.first as Map<String, dynamic>;
      expect(first['id'], equals('uuid-1'));
      expect(first['title'], equals('Coffee Grinder'));
      expect(first['explanation'], equals('Used to grind coffee beans.'));
      expect(first['confidence'], equals('high'));
      expect(first['createdAt'], equals('2026-10-03T15:12:00.000Z'));
      expect(first['location'], isNotNull);
      expect(first['location']['latitude'], equals(28.6139));
      expect(first['location']['longitude'], equals(77.2090));
    });

    test('Serializes discovery without location as location: null (not (0,0))', () {
      final discovery = Discovery.create(
        id: 'uuid-2',
        createdAt: DateTime.utc(2026, 10, 3, 12, 0, 0),
        imagePath: '/path/to/img.jpg',
        location: null,
        identificationResult: const IdentificationResult(
          title: 'Mystery Plant',
          explanation: 'Unknown species.',
          confidence: IdentificationConfidence.unknown,
          identifiable: false,
        ),
      );

      final jsonString = DiscoveryCollectionExportSerializer.serialize(
        discoveries: [discovery],
        exportedAt: fixedExportDate,
      );

      final Map<String, dynamic> parsed = jsonDecode(jsonString);
      final first = (parsed['discoveries'] as List).first as Map<String, dynamic>;
      expect(first['location'], isNull);
    });

    test('Preserves list order and handles special characters, quotes, and unicode/emojis', () {
      final d1 = Discovery.create(
        id: 'uuid-emoji',
        createdAt: DateTime.utc(2026, 10, 3, 17, 0, 0),
        imagePath: 'img1.jpg',
        identificationResult: const IdentificationResult(
          title: 'Special "Brew" ☕ & Tea 🫖',
          explanation: 'Line 1\nLine 2 with \'quotes\' and \\backslashes\\',
          confidence: IdentificationConfidence.medium,
          identifiable: true,
        ),
      );

      final d2 = Discovery.create(
        id: 'uuid-regular',
        createdAt: DateTime.utc(2026, 10, 3, 16, 0, 0),
        imagePath: 'img2.jpg',
        identificationResult: const IdentificationResult(
          title: 'Lamp',
          explanation: 'Desk lighting.',
          confidence: IdentificationConfidence.low,
          identifiable: true,
        ),
      );

      final jsonString = DiscoveryCollectionExportSerializer.serialize(
        discoveries: [d1, d2],
        exportedAt: fixedExportDate,
      );

      final Map<String, dynamic> parsed = jsonDecode(jsonString);
      final list = parsed['discoveries'] as List;
      expect(list.length, equals(2));
      expect(list[0]['id'], equals('uuid-emoji'));
      expect(list[0]['title'], equals('Special "Brew" ☕ & Tea 🫖'));
      expect(list[0]['explanation'], equals('Line 1\nLine 2 with \'quotes\' and \\backslashes\\'));
      expect(list[1]['id'], equals('uuid-regular'));
    });
  });
}
