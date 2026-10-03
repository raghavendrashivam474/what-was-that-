import '../entities/discovery.dart';

abstract class DiscoveryRepository {
  /// Persists a new discovery.
  Future<void> save(Discovery discovery);

  /// Retrieves all saved discoveries, ordered newest first.
  Future<List<Discovery>> getAll();

  /// Retrieves a specific discovery by its ID. Returns null if not found.
  Future<Discovery?> getById(String id);

  /// Deletes a discovery record and removes its associated persistent image.
  Future<void> delete(String id);
}
