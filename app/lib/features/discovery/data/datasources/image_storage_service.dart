import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';

abstract class ImageStorageService {
  Future<String> saveImagePermanently(String tempPath);
  Future<void> deleteImage(String persistentPath);
}

class LocalImageStorageService implements ImageStorageService {
  final Future<Directory> Function()? getDirectory;

  LocalImageStorageService({this.getDirectory});

  @override
  Future<String> saveImagePermanently(String tempPath) async {
    try {
      final tempFile = File(tempPath);
      if (!await tempFile.exists()) {
        throw const ImagePersistenceFailure('Source image file not found.');
      }

      final baseDir = getDirectory != null
          ? await getDirectory!()
          : await getApplicationDocumentsDirectory();

      final discoveriesDir = Directory(p.join(baseDir.path, 'discoveries'));
      if (!await discoveriesDir.exists()) {
        await discoveriesDir.create(recursive: true);
      }

      final ext = p.extension(tempPath).isNotEmpty ? p.extension(tempPath) : '.jpg';
      final fileName = '${const Uuid().v4()}$ext';
      final persistentPath = p.join(discoveriesDir.path, fileName);

      await tempFile.copy(persistentPath);
      return persistentPath;
    } catch (e) {
      if (e is ImagePersistenceFailure) rethrow;
      throw const ImagePersistenceFailure(
        "Couldn't save the captured image. Please try again.",
      );
    }
  }

  @override
  Future<void> deleteImage(String persistentPath) async {
    try {
      final file = File(persistentPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Avoid crash on best-effort file cleanup
    }
  }
}
