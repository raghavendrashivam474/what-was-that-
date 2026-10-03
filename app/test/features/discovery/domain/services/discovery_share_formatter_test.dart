import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery_location.dart';
import 'package:what_was_that/features/discovery/domain/services/discovery_share_formatter.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';

void main() {
  group('DiscoveryShareFormatter Tests', () {
    final testDate = DateTime(2026, 10, 3, 20, 42); // Oct 3, 2026 at 8:42 PM

    test('Formats identifiable discovery with location', () {
      final discovery = Discovery.create(
        id: 'test-id',
        createdAt: testDate,
        imagePath: 'some/path/image.jpg',
        location: const DiscoveryLocation(latitude: 28.6139, longitude: 77.2090),
        identificationResult: const IdentificationResult(
          title: 'Coffee Grinder',
          explanation: 'A device used to grind coffee beans.',
          confidence: IdentificationConfidence.high,
          identifiable: true,
        ),
      );

      final result = DiscoveryShareFormatter.format(discovery);

      expect(result, contains('What Was That?'));
      expect(result, contains('Coffee Grinder'));
      expect(result, contains('High confidence'));
      expect(result, contains('A device used to grind coffee beans.'));
      expect(result, contains('Discovered: October 3, 2026 at 8:42 PM'));
      expect(result, contains('Location:'));
      expect(result, contains('28.613900, 77.209000'));
    });

    test('Formats discovery without location and unidentifiable', () {
      final discovery = Discovery.create(
        id: 'test-id',
        createdAt: testDate,
        imagePath: 'some/path/image.jpg',
        location: null,
        identificationResult: const IdentificationResult(
          title: 'Unidentified Object',
          explanation: 'Could not recognize this item.',
          confidence: IdentificationConfidence.unknown,
          identifiable: false,
        ),
      );

      final result = DiscoveryShareFormatter.format(discovery);

      expect(result, contains('What Was That?'));
      expect(result, contains('Unidentified Object'));
      expect(result, isNot(contains('confidence'))); // unidentifiable hides confidence
      expect(result, contains('Could not recognize this item.'));
      expect(result, contains('Discovered: October 3, 2026 at 8:42 PM'));
      expect(result, isNot(contains('Location:')));
    });

    test('Handles special characters and emojis correctly', () {
      final discovery = Discovery.create(
        createdAt: testDate,
        imagePath: 'path.jpg',
        identificationResult: const IdentificationResult(
          title: 'Café Mug ☕',
          explanation: 'A mug for "delicious" brew.',
          confidence: IdentificationConfidence.medium,
          identifiable: true,
        ),
      );

      final result = DiscoveryShareFormatter.format(discovery);
      expect(result, contains('Café Mug ☕'));
      expect(result, contains('A mug for "delicious" brew.'));
    });
  });
}
