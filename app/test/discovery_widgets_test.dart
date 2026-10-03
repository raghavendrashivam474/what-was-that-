import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/data/datasources/image_storage_service.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery_location.dart';
import 'package:what_was_that/features/discovery/domain/providers/location_provider.dart';
import 'package:what_was_that/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:what_was_that/features/discovery/presentation/screens/discovery_detail_screen.dart';
import 'package:what_was_that/features/discovery/presentation/screens/discovery_list_screen.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';
import 'package:what_was_that/features/identification/domain/repositories/image_identifier.dart';
import 'package:what_was_that/features/identification/presentation/screens/result_screen.dart';

class FakeDiscoveryRepository implements DiscoveryRepository {
  final List<Discovery> discoveries = [];

  @override
  Future<void> save(Discovery discovery) async {
    final index = discoveries.indexWhere((d) => d.id == discovery.id);
    if (index >= 0) {
      discoveries[index] = discovery;
    } else {
      discoveries.insert(0, discovery);
    }
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

class FakeImageIdentifier implements ImageIdentifier {
  @override
  Future<IdentificationResult> identify(String imagePath) async {
    return const IdentificationResult(
      identifiable: true,
      title: 'Monstera Deliciosa',
      explanation: 'A popular houseplant.',
      confidence: IdentificationConfidence.high,
    );
  }
}

class FakeImageStorageService implements ImageStorageService {
  @override
  Future<String> saveImagePermanently(String tempPath) async {
    return '/fake/storage/persisted_$tempPath';
  }

  @override
  Future<void> deleteImage(String imagePath) async {}
}

class FakeNoOpLocationProvider implements LocationProvider {
  @override
  Future<DiscoveryLocation?> getCurrentLocation() async => null;
}

void main() {
  late FakeDiscoveryRepository repository;
  late FakeImageIdentifier identifier;
  late FakeImageStorageService imageStorageService;

  setUp(() {
    repository = FakeDiscoveryRepository();
    identifier = FakeImageIdentifier();
    imageStorageService = FakeImageStorageService();
  });

  group('Discovery Widgets', () {
    testWidgets('DiscoveryListScreen shows empty state when repository is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiscoveryListScreen(
            repository: repository,
            identifier: identifier,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No discoveries yet'), findsOneWidget);
      expect(find.text('What is this?'), findsOneWidget);
    });

    testWidgets('DiscoveryListScreen lists saved discoveries', (tester) async {
      final discovery = Discovery.create(
        identificationResult: const IdentificationResult(
          identifiable: true,
          title: 'Monstera Deliciosa',
          explanation: 'A popular houseplant known as the Swiss cheese plant.',
          confidence: IdentificationConfidence.high,
        ),
        imagePath: 'sample_image.jpg',
      );

      await repository.save(discovery);

      await tester.pumpWidget(
        MaterialApp(
          home: DiscoveryListScreen(
            repository: repository,
            identifier: identifier,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Monstera Deliciosa'), findsOneWidget);
      expect(find.text('High confidence'), findsOneWidget);
    });

    testWidgets('DiscoveryDetailScreen displays discovery details', (tester) async {
      final discovery = Discovery.create(
        identificationResult: const IdentificationResult(
          identifiable: true,
          title: 'Monstera Deliciosa',
          explanation: 'A popular houseplant known as the Swiss cheese plant.',
          confidence: IdentificationConfidence.high,
        ),
        imagePath: 'sample_image.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DiscoveryDetailScreen(
            discovery: discovery,
            repository: repository,
          ),
        ),
      );

      expect(find.text('Monstera Deliciosa'), findsOneWidget);
      expect(find.text('A popular houseplant known as the Swiss cheese plant.'), findsOneWidget);
      expect(find.text('Confidence: High'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('DiscoveryDetailScreen deletes discovery on user confirmation', (tester) async {
      final discovery = Discovery.create(
        identificationResult: const IdentificationResult(
          identifiable: true,
          title: 'Monstera Deliciosa',
          explanation: 'A popular houseplant known as the Swiss cheese plant.',
          confidence: IdentificationConfidence.high,
        ),
        imagePath: 'sample_image.jpg',
      );

      await repository.save(discovery);

      await tester.pumpWidget(
        MaterialApp(
          home: DiscoveryDetailScreen(
            discovery: discovery,
            repository: repository,
          ),
        ),
      );

      // Tap delete icon in AppBar
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Delete this discovery?'), findsOneWidget);

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
            locationProvider: FakeNoOpLocationProvider(),
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
      expect(repository.discoveries.length, equals(1));
      expect(repository.discoveries.first.title, equals('Monstera Deliciosa'));
    });
  });
}
