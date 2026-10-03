import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/data/datasources/discovery_database.dart';
import 'package:what_was_that/features/discovery/data/datasources/image_storage_service.dart';
import 'package:what_was_that/features/discovery/data/repositories/drift_discovery_repository.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';

void main() {
  late AppDatabase db;
  late DriftDiscoveryRepository repository;
  late Directory tempDir;
  late LocalImageStorageService imageStorageService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wwt_test_');
    imageStorageService = LocalImageStorageService(getDirectory: () async => tempDir);
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftDiscoveryRepository(
      database: db,
      imageStorageService: imageStorageService,
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Discovery createSampleDiscovery({
    required String id,
    required String title,
    required DateTime createdAt,
    required String imagePath,
  }) {
    return Discovery(
      id: id,
      imagePath: imagePath,
      createdAt: createdAt,
      identificationResult: IdentificationResult(
        identifiable: true,
        title: title,
        explanation: 'Description of $title',
        confidence: IdentificationConfidence.high,
      ),
    );
  }

  group('DriftDiscoveryRepository Persistence Tests', () {
    test('save and retrieve by ID', () async {
      final discovery = createSampleDiscovery(
        id: 'disc-1',
        title: 'USB-C Cable',
        createdAt: DateTime(2026, 10, 3, 10, 0),
        imagePath: '/mock/path/1.jpg',
      );

      await repository.save(discovery);
      final retrieved = await repository.getById('disc-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'disc-1');
      expect(retrieved.title, 'USB-C Cable');
      expect(retrieved.explanation, 'Description of USB-C Cable');
      expect(retrieved.confidence, IdentificationConfidence.high);
    });

    test('getAll returns items newest first', () async {
      final older = createSampleDiscovery(
        id: 'disc-old',
        title: 'Older Discovery',
        createdAt: DateTime(2026, 10, 1, 10, 0),
        imagePath: '/mock/path/old.jpg',
      );
      final newer = createSampleDiscovery(
        id: 'disc-new',
        title: 'Newer Discovery',
        createdAt: DateTime(2026, 10, 4, 10, 0),
        imagePath: '/mock/path/new.jpg',
      );

      await repository.save(older);
      await repository.save(newer);

      final list = await repository.getAll();
      expect(list.length, 2);
      expect(list.first.id, 'disc-new');
      expect(list.last.id, 'disc-old');
    });

    test('delete removes database record and deletes associated image file', () async {
      // 1. Create a dummy image in temp
      final dummySource = File('${tempDir.path}/temp_capture.jpg');
      await dummySource.writeAsString('mock image content');

      // 2. Persist it using ImageStorageService
      final persistentImagePath = await imageStorageService.saveImagePermanently(dummySource.path);
      expect(await File(persistentImagePath).exists(), isTrue);

      // 3. Save discovery
      final discovery = createSampleDiscovery(
        id: 'disc-to-delete',
        title: 'To Delete',
        createdAt: DateTime.now(),
        imagePath: persistentImagePath,
      );
      await repository.save(discovery);

      // 4. Delete discovery
      await repository.delete('disc-to-delete');

      // 5. Verify database and file are gone
      final retrieved = await repository.getById('disc-to-delete');
      expect(retrieved, isNull);
      expect(await File(persistentImagePath).exists(), isFalse);
    });
  });

  group('ImageStorageService Tests', () {
    test('copies temp file to persistent storage', () async {
      final tempFile = File('${tempDir.path}/source.jpg');
      await tempFile.writeAsString('binary-data');

      final savedPath = await imageStorageService.saveImagePermanently(tempFile.path);

      expect(savedPath, isNot(tempFile.path));
      expect(await File(savedPath).exists(), isTrue);
      expect(await File(savedPath).readAsString(), 'binary-data');
    });
  });
}
