import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:what_was_that/features/discovery/domain/services/discovery_exporter.dart';
import 'package:what_was_that/features/discovery/presentation/screens/discovery_list_screen.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';
import 'package:what_was_that/features/identification/domain/repositories/image_identifier.dart';

class MockDiscoveryRepository implements DiscoveryRepository {
  List<Discovery> discoveries = [];

  @override
  Future<void> delete(String id) async {
    discoveries.removeWhere((d) => d.id == id);
  }

  @override
  Future<List<Discovery>> getAll() async => discoveries;

  @override
  Future<Discovery?> getById(String id) async {
    final matches = discoveries.where((d) => d.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> save(Discovery discovery) async {
    discoveries.insert(0, discovery);
  }
}

class MockImageIdentifier implements ImageIdentifier {
  @override
  Future<IdentificationResult> identify(String imagePath) async {
    return const IdentificationResult(
      title: 'Mock Item',
      explanation: 'Mock Explanation',
      confidence: IdentificationConfidence.high,
      identifiable: true,
    );
  }
}

class FakeDiscoveryExporter implements DiscoveryExporter {
  List<Discovery>? exported;
  bool shouldThrow = false;

  @override
  Future<String> export(List<Discovery> discoveries) async {
    if (shouldThrow) {
      throw Exception('Disk/Share export error');
    }
    if (discoveries.isEmpty) {
      throw ArgumentError('Empty collection');
    }
    exported = discoveries;
    return 'test_export.json';
  }
}

void main() {
  late MockDiscoveryRepository repo;
  late MockImageIdentifier identifier;
  late FakeDiscoveryExporter exporter;

  setUp(() {
    repo = MockDiscoveryRepository();
    identifier = MockImageIdentifier();
    exporter = FakeDiscoveryExporter();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: DiscoveryListScreen(
        repository: repo,
        identifier: identifier,
        exporter: exporter,
      ),
    );
  }

  testWidgets('Export button displays SnackBar when collection is empty', (tester) async {
    repo.discoveries = [];

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final exportButton = find.byKey(const Key('export_discoveries_button'));
    expect(exportButton, findsOneWidget);

    await tester.tap(exportButton);
    await tester.pump();

    expect(find.text('No discoveries to export yet.'), findsOneWidget);
    expect(exporter.exported, isNull);
  });

  testWidgets('Export button exports all discoveries when items exist', (tester) async {
    final d1 = Discovery.create(
      id: 'item-1',
      imagePath: 'img1.jpg',
      identificationResult: const IdentificationResult(
        title: 'Teapot',
        explanation: 'For brewing tea.',
        confidence: IdentificationConfidence.high,
        identifiable: true,
      ),
    );
    final d2 = Discovery.create(
      id: 'item-2',
      imagePath: 'img2.jpg',
      identificationResult: const IdentificationResult(
        title: 'Plant',
        explanation: 'House plant.',
        confidence: IdentificationConfidence.medium,
        identifiable: true,
      ),
    );

    repo.discoveries = [d1, d2];

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final exportButton = find.byKey(const Key('export_discoveries_button'));
    await tester.tap(exportButton);
    await tester.pumpAndSettle();

    expect(exporter.exported, isNotNull);
    expect(exporter.exported?.length, equals(2));
    expect(exporter.exported?[0].id, equals('item-1'));
    expect(exporter.exported?[1].id, equals('item-2'));
  });

  testWidgets('Handles export failure gracefully by displaying error SnackBar', (tester) async {
    repo.discoveries = [
      Discovery.create(
        id: 'item-1',
        imagePath: 'img1.jpg',
        identificationResult: const IdentificationResult(
          title: 'Teapot',
          explanation: 'For brewing tea.',
          confidence: IdentificationConfidence.high,
          identifiable: true,
        ),
      ),
    ];
    exporter.shouldThrow = true;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final exportButton = find.byKey(const Key('export_discoveries_button'));
    await tester.tap(exportButton);
    await tester.pump();

    expect(find.text("Couldn't export discoveries. Please try again."), findsOneWidget);
  });
}
