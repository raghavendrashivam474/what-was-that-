import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery_location.dart';
import 'package:what_was_that/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:what_was_that/features/discovery/presentation/screens/discovery_detail_screen.dart';
import 'package:what_was_that/features/discovery/presentation/screens/discovery_map_screen.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';

class StubRepo implements DiscoveryRepository {
  final List<Discovery> list;
  StubRepo(this.list);

  @override
  Future<void> save(Discovery discovery) async => list.add(discovery);

  @override
  Future<List<Discovery>> getAll() async => list;

  @override
  Future<Discovery?> getById(String id) async => list.where((d) => d.id == id).firstOrNull;

  @override
  Future<void> delete(String id) async => list.removeWhere((d) => d.id == id);
}

void main() {
  group('DiscoveryDetailScreen Location Context', () {
    testWidgets('shows coordinates and "View on Map" button when location present', (tester) async {
      final discovery = Discovery.create(
        identificationResult: const IdentificationResult(
          identifiable: true,
          title: 'Desk Lamp',
          explanation: 'Art-deco metal desk lamp.',
          confidence: IdentificationConfidence.high,
        ),
        imagePath: '/tmp/lamp.jpg',
        location: const DiscoveryLocation(latitude: 37.7749, longitude: -122.4194),
      );
      final repo = StubRepo([discovery]);

      await tester.pumpWidget(
        MaterialApp(
          home: DiscoveryDetailScreen(
            discovery: discovery,
            repository: repo,
          ),
        ),
      );

      expect(find.text('Location Context'), findsOneWidget);
      expect(find.textContaining('Lat: 37.77490, Lon: -122.41940'), findsOneWidget);
      expect(find.text('View on Map'), findsOneWidget);
    });

    testWidgets('shows location not available message when location is null', (tester) async {
      final discovery = Discovery.create(
        identificationResult: const IdentificationResult(
          identifiable: true,
          title: 'Desk Lamp',
          explanation: 'Art-deco metal desk lamp.',
          confidence: IdentificationConfidence.high,
        ),
        imagePath: '/tmp/lamp.jpg',
        location: null,
      );
      final repo = StubRepo([discovery]);

      await tester.pumpWidget(
        MaterialApp(
          home: DiscoveryDetailScreen(
            discovery: discovery,
            repository: repo,
          ),
        ),
      );

      expect(find.text('Location Context'), findsOneWidget);
      expect(find.text('Location context was not captured for this discovery.'), findsOneWidget);
      expect(find.text('View on Map'), findsNothing);
    });
  });

  group('DiscoveryMapScreen Empty & Populated States', () {
    testWidgets('displays empty state when no discoveries have location', (tester) async {
      final unlocatedDiscovery = Discovery.create(
        identificationResult: const IdentificationResult(
          identifiable: true,
          title: 'Unlocated Item',
          explanation: 'No coordinates',
          confidence: IdentificationConfidence.medium,
        ),
        imagePath: '/tmp/item.jpg',
        location: null,
      );
      final repo = StubRepo([unlocatedDiscovery]);

      await tester.pumpWidget(
        MaterialApp(
          home: DiscoveryMapScreen(
            repository: repo,
            enableTileLayer: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No mapped discoveries yet'), findsOneWidget);
      expect(find.text('Discoveries saved with location will appear on this map.'), findsOneWidget);
    });

    testWidgets('loads map screen and displays markers when located discoveries exist', (tester) async {
      final locatedDiscovery = Discovery.create(
        identificationResult: const IdentificationResult(
          identifiable: true,
          title: 'Located Plant',
          explanation: 'Fern in botanical garden',
          confidence: IdentificationConfidence.high,
        ),
        imagePath: '/tmp/plant.jpg',
        location: const DiscoveryLocation(latitude: 48.8566, longitude: 2.3522),
      );
      final repo = StubRepo([locatedDiscovery]);

      await tester.pumpWidget(
        MaterialApp(
          home: DiscoveryMapScreen(
            repository: repo,
            enableTileLayer: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Discovery Map'), findsOneWidget);
      expect(find.text('No mapped discoveries yet'), findsNothing);
      expect(find.byIcon(Icons.location_on), findsOneWidget);

      // Tap marker and verify preview card pops up
      await tester.tap(find.byIcon(Icons.location_on));
      await tester.pumpAndSettle();

      expect(find.text('Located Plant'), findsOneWidget);
      expect(find.text('High confidence'), findsOneWidget);
    });
  });
}
