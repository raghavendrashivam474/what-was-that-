import 'package:drift/drift.dart';
import '../../../../core/errors/failures.dart';
import '../../../identification/domain/entities/identification_result.dart';
import '../../domain/entities/discovery.dart';
import '../../domain/entities/discovery_location.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../datasources/discovery_database.dart';
import '../datasources/image_storage_service.dart';

class DriftDiscoveryRepository implements DiscoveryRepository {
  final AppDatabase database;
  final ImageStorageService? imageStorageService;

  DriftDiscoveryRepository({
    required this.database,
    this.imageStorageService,
  });

  @override
  Future<void> save(Discovery discovery) async {
    try {
      await database.into(database.discoveries).insertOnConflictUpdate(
            DiscoveriesCompanion.insert(
              id: discovery.id,
              title: discovery.title,
              explanation: discovery.explanation,
              confidence: discovery.confidence.name,
              identifiable: Value(discovery.identifiable),
              imagePath: discovery.imagePath,
              createdAt: discovery.createdAt,
              latitude: Value(discovery.location?.latitude),
              longitude: Value(discovery.location?.longitude),
            ),
          );
    } catch (e) {
      throw const StorageFailure();
    }
  }

  @override
  Future<List<Discovery>> getAll() async {
    try {
      final rows = await (database.select(database.discoveries)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();
      return rows.map(_mapEntryToDiscovery).toList();
    } catch (e) {
      throw const StorageFailure();
    }
  }

  @override
  Future<Discovery?> getById(String id) async {
    try {
      final row = await (database.select(database.discoveries)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return null;
      return _mapEntryToDiscovery(row);
    } catch (e) {
      throw const StorageFailure();
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final existing = await getById(id);
      if (existing != null) {
        if (imageStorageService != null) {
          await imageStorageService!.deleteImage(existing.imagePath);
        }
        await (database.delete(database.discoveries)
              ..where((t) => t.id.equals(id)))
            .go();
      }
    } catch (e) {
      throw const StorageFailure();
    }
  }

  Discovery _mapEntryToDiscovery(DiscoveryEntry entry) {
    DiscoveryLocation? location;
    if (entry.latitude != null && entry.longitude != null) {
      location = DiscoveryLocation(
        latitude: entry.latitude!,
        longitude: entry.longitude!,
      );
    }

    return Discovery(
      id: entry.id,
      imagePath: entry.imagePath,
      createdAt: entry.createdAt,
      location: location,
      identificationResult: IdentificationResult(
        identifiable: entry.identifiable,
        title: entry.title,
        explanation: entry.explanation,
        confidence: IdentificationConfidence.fromString(entry.confidence),
      ),
    );
  }
}
