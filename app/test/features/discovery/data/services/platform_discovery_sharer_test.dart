import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/services/discovery_sharer.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';

/// A pure unit-testable Fake of the DiscoverySharer interface to ensure
/// we correctly pass downstream discoveries and avoid native platform exceptions.
class FakeDiscoverySharer implements DiscoverySharer {
  Discovery? lastSharedDiscovery;
  int shareCount = 0;

  @override
  Future<void> share(Discovery discovery) async {
    lastSharedDiscovery = discovery;
    shareCount++;
  }
}

void main() {
  group('DiscoverySharer Abstraction Tests', () {
    test('FakeDiscoverySharer captures shared items correctly without real platforms', () async {
      final sharer = FakeDiscoverySharer();
      final discovery = Discovery.create(
        id: 'test-uuid-999',
        imagePath: 'non_existent_mock_image.jpg',
        identificationResult: const IdentificationResult(
          title: 'Mechanical Keyboard',
          explanation: 'Tactile typing hardware.',
          confidence: IdentificationConfidence.high,
          identifiable: true,
        ),
      );

      await sharer.share(discovery);

      expect(sharer.shareCount, equals(1));
      expect(sharer.lastSharedDiscovery?.id, equals('test-uuid-999'));
      expect(sharer.lastSharedDiscovery?.title, equals('Mechanical Keyboard'));
    });
  });
}
