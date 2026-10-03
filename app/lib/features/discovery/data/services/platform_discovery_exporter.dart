import 'dart:io';
import 'package:path_provider/path_provider.dart';
// ignore: deprecated_member_use
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/discovery.dart';
import '../../domain/services/discovery_collection_export_serializer.dart';
import '../../domain/services/discovery_exporter.dart';

class PlatformDiscoveryExporter implements DiscoveryExporter {
  final Future<Directory> Function()? getDirectoryOverride;

  const PlatformDiscoveryExporter({this.getDirectoryOverride});

  @override
  Future<String> export(List<Discovery> discoveries) async {
    if (discoveries.isEmpty) {
      throw ArgumentError('Cannot export an empty collection of discoveries.');
    }

    final jsonString = DiscoveryCollectionExportSerializer.serialize(
      discoveries: discoveries,
    );

    final dir = getDirectoryOverride != null 
        ? await getDirectoryOverride!() 
        : await getTemporaryDirectory();

    final now = DateTime.now();
    final formattedDate = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final timestamp = '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';

    final fileName = 'what-was-that-discoveries-$formattedDate-$timestamp.json';
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');

    await file.writeAsString(jsonString);

    // ignore: deprecated_member_use
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'What Was That - Discoveries Export',
    );

    return file.path;
  }
}
