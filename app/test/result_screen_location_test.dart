import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/data/datasources/image_storage_service.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery_location.dart';
import 'package:what_was_that/features/discovery/domain/providers/location_provider.dart';
import 'package:what_was_that/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';
import 'package:what_was_that/features/identification/presentation/screens/result_screen.dart';

class MockDiscoveryRepository implements DiscoveryRepository {
  final List<Discovery> stored = [];

  @override
  Future<void> save(Discovery discovery) async {
    stored.add(discovery);
  }

  @override
  Future<List<Discovery>> getAll() async => stored;

  @override
  Future<Discovery?> getById(String id) async {
    return stored.where((d) => d.id == id).firstOrNull;
  }

  @override
  Future<void> delete(String id) async {
    stored.removeWhere((d) => d.id == id);
  }
}

class MockImageStorageService implements ImageStorageService {
  @override
  Future<String> saveImagePermanently(String tempPath) async {
    return '/persisted/$tempPath';
  }

  @override
  Future<void> deleteImage(String imagePath) async {}
}

class SuccessLocationProvider implements LocationProvider {
  final DiscoveryLocation location;
  SuccessLocationProvider(this.location);

  @override
  Future<DiscoveryLocation?> getCurrentLocation() async => location;
}

class FailureLocationProvider implements LocationProvider {
  @override
  Future<DiscoveryLocation?> getCurrentLocation() async {
    throw Exception('GPS timeout or permission denied');
  }
}

class NullLocationProvider implements LocationProvider {
  @override
  Future<DiscoveryLocation?> getCurrentLocation() async => null;
}

void main() {
  group('ResultScreen Location Capture & Fallback', () {
    testWidgets('attaches location when LocationProvider succeeds', (tester) async {
      final repo = MockDiscoveryRepository();
      final storage = MockImageStorageService();
      final locProvider = SuccessLocationProvider(
        const DiscoveryLocation(latitude: 52.5200, longitude: 13.4050),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ResultScreen(
            imagePath: 'sample.jpg',
            result: const IdentificationResult(
              identifiable: true,
              title: 'Espresso Machine',
              explanation: 'Italian espresso maker',
              confidence: IdentificationConfidence.high,
            ),
            repository: repo,
            imageStorageService: storage,
            locationProvider: locProvider,
          ),
        ),
      );

      await tester.tap(find.text('Save Discovery'));
      await tester.pumpAndSettle();

      expect(find.text('Saved to your discoveries'), findsOneWidget);
      expect(repo.stored.length, equals(1));
      expect(repo.stored.first.location, isNotNull);
      expect(repo.stored.first.location!.latitude, equals(52.5200));
      expect(repo.stored.first.location!.longitude, equals(13.4050));
    });

    testWidgets('still saves successfully when LocationProvider returns null (denied/disabled)', (tester) async {
      final repo = MockDiscoveryRepository();
      final storage = MockImageStorageService();
      final locProvider = NullLocationProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ResultScreen(
            imagePath: 'sample.jpg',
            result: const IdentificationResult(
              identifiable: true,
              title: 'Espresso Machine',
              explanation: 'Italian espresso maker',
              confidence: IdentificationConfidence.high,
            ),
            repository: repo,
            imageStorageService: storage,
            locationProvider: locProvider,
          ),
        ),
      );

      await tester.tap(find.text('Save Discovery'));
      await tester.pumpAndSettle();

      expect(find.text('Saved to your discoveries'), findsOneWidget);
      expect(repo.stored.length, equals(1));
      expect(repo.stored.first.location, isNull);
    });

    testWidgets('still saves successfully when LocationProvider throws error/timeout', (tester) async {
      final repo = MockDiscoveryRepository();
      final storage = MockImageStorageService();
      final locProvider = FailureLocationProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ResultScreen(
            imagePath: 'sample.jpg',
            result: const IdentificationResult(
              identifiable: true,
              title: 'Espresso Machine',
              explanation: 'Italian espresso maker',
              confidence: IdentificationConfidence.high,
            ),
            repository: repo,
            imageStorageService: storage,
            locationProvider: locProvider,
          ),
        ),
      );

      await tester.tap(find.text('Save Discovery'));
      await tester.pumpAndSettle();

      expect(find.text('Saved to your discoveries'), findsOneWidget);
      expect(repo.stored.length, equals(1));
      expect(repo.stored.first.location, isNull);
    });
  });
}
