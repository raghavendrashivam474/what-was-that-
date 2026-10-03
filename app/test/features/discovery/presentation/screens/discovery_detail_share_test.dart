import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery_location.dart';
import 'package:what_was_that/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:what_was_that/features/discovery/domain/services/discovery_sharer.dart';
import 'package:what_was_that/features/discovery/presentation/screens/discovery_detail_screen.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';

class MockDiscoveryRepository implements DiscoveryRepository {
  @override
  Future<void> delete(String id) async {}
  @override
  Future<List<Discovery>> getAll() async => [];
  @override
  Future<Discovery?> getById(String id) async => null;
  @override
  Future<void> save(Discovery discovery) async {}
}

class FakeDiscoverySharer implements DiscoverySharer {
  Discovery? sharedDiscovery;
  bool shouldThrow = false;

  @override
  Future<void> share(Discovery discovery) async {
    if (shouldThrow) {
      throw Exception('Platform share error');
    }
    sharedDiscovery = discovery;
  }
}

void main() {
  late MockDiscoveryRepository repo;
  late FakeDiscoverySharer fakeSharer;
  late Discovery sampleDiscovery;

  setUp(() {
    repo = MockDiscoveryRepository();
    fakeSharer = FakeDiscoverySharer();
    sampleDiscovery = Discovery.create(
      id: 'detail-share-123',
      imagePath: 'sample.jpg',
      location: const DiscoveryLocation(latitude: 37.7749, longitude: -122.4194),
      identificationResult: const IdentificationResult(
        title: 'Golden Gate Bridge',
        explanation: 'A suspension bridge spanning the Golden Gate strait.',
        confidence: IdentificationConfidence.high,
        identifiable: true,
      ),
    );
  });

  testWidgets('Renders Share button in AppBar and calls sharer on tap', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DiscoveryDetailScreen(
          discovery: sampleDiscovery,
          repository: repo,
          sharer: fakeSharer,
        ),
      ),
    );

    final shareButtonFinder = find.byKey(const Key('share_discovery_button'));
    expect(shareButtonFinder, findsOneWidget);

    await tester.tap(shareButtonFinder);
    await tester.pumpAndSettle();

    expect(fakeSharer.sharedDiscovery, isNotNull);
    expect(fakeSharer.sharedDiscovery?.id, equals('detail-share-123'));
    expect(fakeSharer.sharedDiscovery?.title, equals('Golden Gate Bridge'));
  });

  testWidgets('Shows SnackBar on share failure without crashing or mutating screen', (tester) async {
    fakeSharer.shouldThrow = true;

    await tester.pumpWidget(
      MaterialApp(
        home: DiscoveryDetailScreen(
          discovery: sampleDiscovery,
          repository: repo,
          sharer: fakeSharer,
        ),
      ),
    );

    final shareButtonFinder = find.byKey(const Key('share_discovery_button'));
    await tester.tap(shareButtonFinder);
    await tester.pump();

    expect(find.text("Couldn't share this discovery. Please try again."), findsOneWidget);
    // Detail screen is still present
    expect(find.text('Golden Gate Bridge'), findsOneWidget);
  });
}
