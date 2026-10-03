import '../entities/discovery.dart';

abstract class DiscoveryExporter {
  /// Serializes and writes discoveries to a JSON file, then invokes the platform file/share sheet.
  /// Returns the file path of the generated JSON export.
  Future<String> export(List<Discovery> discoveries);
}
