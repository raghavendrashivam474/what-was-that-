import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/data/datasources/image_storage_service.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:what_was_that/features/discovery/presentation/screens/discovery_detail_screen.dart';
import 'package:what_was_that/features/discovery/presentation/screens/discovery_list_screen.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';
import 'package:what_was_that/features/identification/domain/repositories/image_identifier.dart';
import 'package:what_was_that/features/identification/presentation/screens/home_screen.dart';
import 'package:what_was_that/features/identification/presentation/screens/result_screen.dart';

class FakeDiscoveryRepository implements DiscoveryRepository {
  final List<Discovery> discoveries = [];

  @override
  Future<void> save(Discovery discovery) async {
    discoveries.insert(0, discovery);
  }

  @override
  Future<List<Discovery>> getAll() async {
    return List.from(discoveries);
  }

  @override
  Future<Discovery?> getById(String id) async {
    try {
      return discoveries.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String id) async {
    discoveries.removeWhere((d) => d.id == id);
  }
}

class FakeImageStorageService implements ImageStorageService {
  @override
  Future<String> saveImagePermanently(String tempPath) async {
    return '/fake/storage/persisted_$tempPath';
  }

  @override
  Future<void> deleteImage(String persistentPath) async {}
}

class FakeImageIdentifier implements ImageIdentifier {
  @override
  Future<IdentificationResult> identify(String imagePath) async {
    return const IdentificationResult(
      identifiable: true,
      title: 'Mock Item',
      explanation: 'Mock Explanation',
      confidence: IdentificationConfidence.high,
    );
  }
}

void main() {
  late FakeDiscoveryRepository repository;
  late FakeImageStorageService imageStorageService;
  late FakeImageIdentifier imageIdentifier;

  setUp(() {
    repository = FakeDiscoveryRepository();
    imageStorageService = FakeImageStorageService();
    imageIdentifier = FakeImageIdentifier();
  });

  Discovery makeSampleDiscovery({
    required String id,
    required String title,
    DateTime? date,
  }) {
    return Discovery(
      id: id,
      imagePath: 'dummy_image.jpg',
      createdAt: date ?? DateTime(2026, 10, 4),
      identificationResult: IdentificationResult(
        identifiable: true,
        title: title,
        explanation: 'Explanation for $title',
        confidence: IdentificationConfidence.high,
      ),
    );
  }

  testWidgets('HomeScreen renders "My Discoveries" button when repository is provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          identifier: imageIdentifier,
          repository: repository,
        ),
      ),
    );

    expect(find.text('WHAT WAS THAT?'), findsOneWidget);
    expect(find.text('What is this?'), findsOneWidget);
    expect(find.text('My Discoveries'), findsOneWidget);
  });

  testWidgets('DiscoveryListScreen renders empty state when no discoveries exist', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DiscoveryListScreen(
          repository: repository,
          identifier: imageIdentifier,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nothing here yet.'), findsOneWidget);
    expect(
      find.text('The next time you discover\nsomething unfamiliar, save it here.'),
      findsOneWidget,
    );
    expect(find.text('What is this?'), findsOneWidget);
  });

  testWidgets('DiscoveryListScreen renders list of saved discoveries', (tester) async {
    repository.discoveries.add(makeSampleDiscovery(id: '1', title: 'Kingfisher'));
    repository.discoveries.add(makeSampleDiscovery(id: '2', title: 'USB-C Port'));

    await tester.pumpWidget(
      MaterialApp(
        home: DiscoveryListScreen(
          repository: repository,
          identifier: imageIdentifier,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kingfisher'), findsOneWidget);
    expect(find.text('USB-C Port'), findsOneWidget);
  });

  testWidgets('DiscoveryDetailScreen displays details and handles delete confirmation', (tester) async {
    final discovery = makeSampleDiscovery(id: 'disc-10', title: 'Vintage Clock');
    repository.discoveries.add(discovery);

    await tester.pumpWidget(
      MaterialApp(
        home: DiscoveryDetailScreen(
          discovery: discovery,
          repository: repository,
        ),
      ),
    );

    expect(find.text('Vintage Clock'), findsOneWidget);
    expect(find.text('Explanation for Vintage Clock'), findsOneWidget);
    expect(find.text('Confidence: High'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    // Tap delete button to open confirmation dialog
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete this discovery?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    // Confirm deletion
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Verify repository deleted the item
    expect(repository.discoveries.isEmpty, isTrue);
  });

  testWidgets('ResultScreen saves discovery on button tap and updates UI', (tester) async {
    const mockResult = IdentificationResult(
      identifiable: true,
      title: 'Monstera Deliciosa',
      explanation: 'A popular houseplant known as the Swiss cheese plant.',
      confidence: IdentificationConfidence.high,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ResultScreen(
          imagePath: 'temp_capture.jpg',
          result: mockResult,
          repository: repository,
          imageStorageService: imageStorageService,
        ),
      ),
    );

    expect(find.text('Save Discovery'), findsOneWidget);
    expect(find.text('Monstera Deliciosa'), findsOneWidget);

    // Tap "Save Discovery"
    await tester.tap(find.text('Save Discovery'));
    await tester.pumpAndSettle();

    // Verify saved state in UI
    expect(find.text('Saved to your discoveries'), findsOneWidget);
    expect(find.text('Save Discovery'), findsNothing);

    // Verify repository received the saved discovery
    expect(repository.discoveries.length, 1);
    expect(repository.discoveries.first.title, 'Monstera Deliciosa');
  });
}
