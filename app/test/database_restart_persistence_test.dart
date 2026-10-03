import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/data/datasources/discovery_database.dart';
import 'package:what_was_that/features/discovery/data/datasources/image_storage_service.dart';
import 'package:what_was_that/features/discovery/data/repositories/drift_discovery_repository.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';

void main() {
  late Directory tempDir;
  late File dbFile;
  late LocalImageStorageService imageStorageService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wwt_restart_test_');
    dbFile = File('${tempDir.path}/wwt_restart_test.sqlite');
    imageStorageService = LocalImageStorageService(getDirectory: () async => tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Persistent SQLite database survives repository shutdown and restart', () async {
    // 1. Session A: Initialize Database, create dummy image, save Discovery
    final dbSessionA = AppDatabase(NativeDatabase(dbFile));
    final repoA = DriftDiscoveryRepository(
      database: dbSessionA,
      imageStorageService: imageStorageService,
    );

    // Create temp image & store permanently
    final tempImage = File('${tempDir.path}/temp_capture.jpg');
    await tempImage.writeAsString('fake-jpeg-bytes');
    final persistedPath = await imageStorageService.saveImagePermanently(tempImage.path);

    final discovery = Discovery.create(
      id: 'session-restart-id-1',
      identificationResult: const IdentificationResult(
        identifiable: true,
        title: 'Kingfisher Bird',
        explanation: 'A small to medium-sized brightly colored bird.',
        confidence: IdentificationConfidence.high,
      ),
      imagePath: persistedPath,
    );

    await repoA.save(discovery);

    // 2. Simulate App Shutdown / Process Kill
    await dbSessionA.close();

    // 3. Session B: App Re-launch with new Database instance pointing to same file
    final dbSessionB = AppDatabase(NativeDatabase(dbFile));
    final repoB = DriftDiscoveryRepository(
      database: dbSessionB,
      imageStorageService: imageStorageService,
    );

    // 4. Verify discovery and image path are intact
    final retrieved = await repoB.getById('session-restart-id-1');
    expect(retrieved, isNotNull);
    expect(retrieved!.id, 'session-restart-id-1');
    expect(retrieved.title, 'Kingfisher Bird');
    expect(retrieved.explanation, 'A small to medium-sized brightly colored bird.');
    expect(retrieved.confidence, IdentificationConfidence.high);
    expect(retrieved.imagePath, persistedPath);
    expect(await File(retrieved.imagePath).exists(), isTrue);

    // 5. Cleanup session B
    await dbSessionB.close();
  });
}
