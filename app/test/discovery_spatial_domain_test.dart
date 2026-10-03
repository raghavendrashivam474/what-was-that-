import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery_location.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';

void main() {
  group('DiscoveryLocation Domain Model', () {
    test('instantiates with latitude and longitude', () {
      const loc = DiscoveryLocation(latitude: 37.7749, longitude: -122.4194);
      expect(loc.latitude, equals(37.7749));
      expect(loc.longitude, equals(-122.4194));
    });

    test('value equality works correctly', () {
      const loc1 = DiscoveryLocation(latitude: 40.7128, longitude: -74.0060);
      const loc2 = DiscoveryLocation(latitude: 40.7128, longitude: -74.0060);
      const loc3 = DiscoveryLocation(latitude: 51.5074, longitude: -0.1278);

      expect(loc1, equals(loc2));
      expect(loc1.hashCode, equals(loc2.hashCode));
      expect(loc1, isNot(equals(loc3)));
    });

    test('supports Discovery with and without location', () {
      final unlocated = Discovery.create(
        identificationResult: const IdentificationResult(
          identifiable: true,
          title: 'Oak Leaf',
          explanation: 'A leaf from an oak tree.',
          confidence: IdentificationConfidence.high,
        ),
        imagePath: '/tmp/oak.jpg',
      );
      expect(unlocated.location, isNull);

      final located = Discovery.create(
        identificationResult: const IdentificationResult(
          identifiable: true,
          title: 'Oak Leaf',
          explanation: 'A leaf from an oak tree.',
          confidence: IdentificationConfidence.high,
        ),
        imagePath: '/tmp/oak.jpg',
        location: const DiscoveryLocation(latitude: 45.0, longitude: 9.0),
      );
      expect(located.location, isNotNull);
      expect(located.location!.latitude, equals(45.0));
      expect(located.location!.longitude, equals(9.0));
    });
  });
}
