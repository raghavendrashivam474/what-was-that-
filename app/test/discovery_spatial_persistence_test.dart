import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/data/datasources/discovery_database.dart';
import 'package:what_was_that/features/discovery/data/repositories/drift_discovery_repository.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery_location.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';

void main() {
  late AppDatabase db;
  late DriftDiscoveryRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftDiscoveryRepository(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftDiscoveryRepository Spatial Persistence', () {
    test('saves and retrieves discovery with location coordinates', () async {
      final discovery = Discovery.create(
        identificationResult: const IdentificationResult(
          identifiable: true,
          title: 'Monstera Deliciosa',
          explanation: 'Tropical plant known for holey leaves.',
          confidence: IdentificationConfidence.high,
        ),
        imagePath: '/images/monstera.jpg',
        location: const DiscoveryLocation(latitude: 34.0522, longitude: -118.2437),
      );

      await repository.save(discovery);

      final retrieved = await repository.getById(discovery.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.location, isNotNull);
      expect(retrieved.location!.latitude, equals(34.0522));
      expect(retrieved.location!.longitude, equals(-118.2437));
    });

    test('saves and retrieves discovery without location gracefully', () async {
      final discovery = Discovery.create(
        identificationResult: const IdentificationResult(
          identifiable: true,
          title: 'Vintage Radio',
          explanation: '1960s transistor radio.',
          confidence: IdentificationConfidence.medium,
        ),
        imagePath: '/images/radio.jpg',
        location: null,
      );

      await repository.save(discovery);

      final retrieved = await repository.getById(discovery.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.location, isNull);
    });

    test('getAll preserves locations and ordering across mixed records', () async {
      final d1 = Discovery(
        id: '1',
        identificationResult: const IdentificationResult(
          identifiable: true,
          title: 'Item 1',
          explanation: 'Exp 1',
          confidence: IdentificationConfidence.high,
        ),
        imagePath: '/p1.jpg',
        createdAt: DateTime(2026, 3, 1, 10, 0),
        location: const DiscoveryLocation(latitude: 10.0, longitude: 20.0),
      );

      final d2 = Discovery(
        id: '2',
        identificationResult: const IdentificationResult(
          identifiable: true,
          title: 'Item 2',
          explanation: 'Exp 2',
          confidence: IdentificationConfidence.low,
        ),
        imagePath: '/p2.jpg',
        createdAt: DateTime(2026, 3, 1, 12, 0),
        location: null,
      );

      await repository.save(d1);
      await repository.save(d2);

      final all = await repository.getAll();
      expect(all.length, equals(2));
      // d2 was created later, should be first
      expect(all[0].id, equals('2'));
      expect(all[0].location, isNull);

      expect(all[1].id, equals('1'));
      expect(all[1].location, isNotNull);
      expect(all[1].location!.latitude, equals(10.0));
      expect(all[1].location!.longitude, equals(20.0));
    });
  });
}
