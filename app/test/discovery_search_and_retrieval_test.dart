import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:what_was_that/features/discovery/presentation/screens/discovery_detail_screen.dart';
import 'package:what_was_that/features/discovery/presentation/screens/discovery_list_screen.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';
import 'package:what_was_that/features/identification/domain/repositories/image_identifier.dart';

class InMemoryDiscoveryRepository implements DiscoveryRepository {
  final List<Discovery> _discoveries = [];

  void addAll(List<Discovery> list) {
    _discoveries.addAll(list);
  }

  @override
  Future<void> save(Discovery discovery) async {
    _discoveries.insert(0, discovery);
  }

  @override
  Future<List<Discovery>> getAll() async {
    // Preserve repository contract: newest first
    final sorted = List<Discovery>.from(_discoveries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<Discovery?> getById(String id) async {
    try {
      return _discoveries.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String id) async {
    _discoveries.removeWhere((d) => d.id == id);
  }
}

class FakeImageIdentifier implements ImageIdentifier {
  @override
  Future<IdentificationResult> identify(String imagePath) async {
    return const IdentificationResult(
      identifiable: true,
      title: 'Fake Item',
      explanation: 'Fake Explanation',
      confidence: IdentificationConfidence.high,
    );
  }
}

Discovery makeDiscovery({
  required String id,
  required String title,
  required String explanation,
  required DateTime createdAt,
  IdentificationConfidence confidence = IdentificationConfidence.high,
}) {
  return Discovery(
    id: id,
    imagePath: 'non_existent_dummy_path.jpg',
    createdAt: createdAt,
    identificationResult: IdentificationResult(
      identifiable: true,
      title: title,
      explanation: explanation,
      confidence: confidence,
    ),
  );
}

void main() {
  late InMemoryDiscoveryRepository repository;
  late FakeImageIdentifier identifier;

  setUp(() {
    repository = InMemoryDiscoveryRepository();
    identifier = FakeImageIdentifier();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: DiscoveryListScreen(
        repository: repository,
        identifier: identifier,
      ),
    );
  }

  group('S3-A: Discovery Search Feature', () {
    testWidgets('Empty search query renders all discoveries', (tester) async {
      final now = DateTime.now();
      repository.addAll([
        makeDiscovery(
          id: '1',
          title: 'Coffee Grinder',
          explanation: 'Burr grinder for espresso beans',
          createdAt: now,
        ),
        makeDiscovery(
          id: '2',
          title: 'Strange Plant',
          explanation: 'Succulent with thick green leaves',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Coffee Grinder'), findsOneWidget);
      expect(find.text('Strange Plant'), findsOneWidget);
    });

    testWidgets('Search matches by title (case-insensitive)', (tester) async {
      final now = DateTime.now();
      repository.addAll([
        makeDiscovery(
          id: '1',
          title: 'Coffee Grinder',
          explanation: 'Kitchen appliance',
          createdAt: now,
        ),
        makeDiscovery(
          id: '2',
          title: 'Mechanical Part',
          explanation: 'Metal gear assembly',
          createdAt: now,
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Type lowercase 'coffee'
      await tester.enterText(find.byKey(const Key('search_field')), 'coffee');
      await tester.pumpAndSettle();

      expect(find.text('Coffee Grinder'), findsOneWidget);
      expect(find.text('Mechanical Part'), findsNothing);

      // Type uppercase 'COFFEE'
      await tester.enterText(find.byKey(const Key('search_field')), 'COFFEE');
      await tester.pumpAndSettle();

      expect(find.text('Coffee Grinder'), findsOneWidget);
      expect(find.text('Mechanical Part'), findsNothing);
    });

    testWidgets('Search matches by explanation text', (tester) async {
      final now = DateTime.now();
      repository.addAll([
        makeDiscovery(
          id: '1',
          title: 'Mystery Item',
          explanation: 'Contains a brass escapement mechanism',
          createdAt: now,
        ),
        makeDiscovery(
          id: '2',
          title: 'Plastic Bottle',
          explanation: 'Standard container for fluids',
          createdAt: now,
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Search for a word only in explanation
      await tester.enterText(find.byKey(const Key('search_field')), 'escapement');
      await tester.pumpAndSettle();

      expect(find.text('Mystery Item'), findsOneWidget);
      expect(find.text('Plastic Bottle'), findsNothing);
    });

    testWidgets('No-match search query displays friendly no-result empty state', (tester) async {
      repository.addAll([
        makeDiscovery(
          id: '1',
          title: 'Coffee Grinder',
          explanation: 'Grinds coffee beans',
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('search_field')), 'unobtainium');
      await tester.pumpAndSettle();

      expect(find.text('Nothing found'), findsOneWidget);
      expect(find.text('Try a different search.'), findsOneWidget);
      expect(find.text('Coffee Grinder'), findsNothing);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('Clearing search restores all discoveries', (tester) async {
      repository.addAll([
        makeDiscovery(
          id: '1',
          title: 'Coffee Grinder',
          explanation: 'Grinder',
          createdAt: DateTime.now(),
        ),
        makeDiscovery(
          id: '2',
          title: 'Desk Lamp',
          explanation: 'Lighting',
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Filter to one
      await tester.enterText(find.byKey(const Key('search_field')), 'lamp');
      await tester.pumpAndSettle();
      expect(find.text('Coffee Grinder'), findsNothing);
      expect(find.text('Desk Lamp'), findsOneWidget);

      // Tap clear icon button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('Coffee Grinder'), findsOneWidget);
      expect(find.text('Desk Lamp'), findsOneWidget);
    });
  });

  group('S3-A: Chronological Ordering & Date Grouping', () {
    testWidgets('Renders items under Today and Yesterday section headers', (tester) async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      repository.addAll([
        makeDiscovery(
          id: '1',
          title: 'Today Discovery',
          explanation: 'Found today',
          createdAt: now,
        ),
        makeDiscovery(
          id: '2',
          title: 'Yesterday Discovery',
          explanation: 'Found yesterday',
          createdAt: yesterday,
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Today Discovery'), findsOneWidget);
      expect(find.text('Yesterday Discovery'), findsOneWidget);
    });

    testWidgets('Renders confidence level and timestamp on discovery cards', (tester) async {
      repository.addAll([
        makeDiscovery(
          id: '1',
          title: 'Monstera Plant',
          explanation: 'Plant with split leaves',
          createdAt: DateTime.now(),
          confidence: IdentificationConfidence.high,
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('High confidence'), findsOneWidget);
      expect(find.textContaining('Today \u00b7'), findsOneWidget);
    });
  });

  group('S3-A: Detail Screen Navigation Continuity', () {
    testWidgets('Tapping discovery navigates to DiscoveryDetailScreen and returns cleanly', (tester) async {
      final discovery = makeDiscovery(
        id: '100',
        title: 'Antique Sextant',
        explanation: 'Navigational instrument',
        createdAt: DateTime.now(),
      );
      repository.addAll([discovery]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on the discovery card
      await tester.tap(find.text('Antique Sextant'));
      await tester.pumpAndSettle();

      // Verify on Detail Screen
      expect(find.byType(DiscoveryDetailScreen), findsOneWidget);
      expect(find.byType(DiscoveryDetailScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      // Verify back on List Screen
      expect(find.byType(DiscoveryListScreen), findsOneWidget);
      expect(find.text('Antique Sextant'), findsOneWidget);
    });
  });
}

