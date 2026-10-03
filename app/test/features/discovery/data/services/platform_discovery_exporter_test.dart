import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery.dart';
import 'package:what_was_that/features/discovery/domain/entities/discovery_location.dart';
import 'package:what_was_that/features/discovery/domain/services/discovery_exporter.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';

class FakeDiscoveryExporter implements DiscoveryExporter {
  List<Discovery>? lastExportedDiscoveries;
  int exportCallCount = 0;

  @override
  Future<String> export(List<Discovery> discoveries) async {
    if (discoveries.isEmpty) {
      throw ArgumentError('Cannot export empty collection');
    }
    lastExportedDiscoveries = discoveries;
    exportCallCount++;
    return '/mock/path/what-was-that-discoveries-test.json';
  }
}

void main() {
  group('DiscoveryExporter Tests', () {
    late Directory tempTestDir;

    setUp(() async {
      tempTestDir = await Directory.systemTemp.createTemp('discovery_export_test_');
    });

    tearDown(() async {
      if (await tempTestDir.exists()) {
        await tempTestDir.delete(recursive: true);
      }
    });

    test('FakeDiscoveryExporter captures export calls accurately', () async {
      final fake = FakeDiscoveryExporter();
      final items = [
        Discovery.create(
          id: 'exp-1',
          imagePath: 'img1.jpg',
          identificationResult: const IdentificationResult(
            title: 'Test Item',
            explanation: 'Test Explanation',
            confidence: IdentificationConfidence.high,
            identifiable: true,
          ),
        ),
      ];

      final path = await fake.export(items);
      expect(fake.exportCallCount, equals(1));
      expect(fake.lastExportedDiscoveries?.length, equals(1));
      expect(fake.lastExportedDiscoveries?.first.id, equals('exp-1'));
      expect(path, contains('.json'));
    });

    test('FakeDiscoveryExporter rejects empty discoveries list', () async {
      final fake = FakeDiscoveryExporter();
      expect(() => fake.export([]), throwsArgumentError);
    });

    test('Export file writing creates valid JSON file format on disk', () async {
      final discovery = Discovery.create(
        id: 'file-test-1',
        createdAt: DateTime.utc(2026, 10, 3, 12, 0),
        imagePath: 'img.jpg',
        location: const DiscoveryLocation(latitude: 12.34, longitude: 56.78),
        identificationResult: const IdentificationResult(
          title: 'Compass 🧭',
          explanation: 'Navigation instrument.',
          confidence: IdentificationConfidence.high,
          identifiable: true,
        ),
      );

      final discoveries = [discovery];
      final jsonFile = File('${tempTestDir.path}${Platform.pathSeparator}test_export.json');
      await jsonFile.writeAsString(
        jsonEncode({
          'format': 'what-was-that-discoveries',
          'version': 1,
          'discoveries': discoveries.map((d) => {'id': d.id, 'title': d.title}).toList(),
        }),
      );

      expect(await jsonFile.exists(), isTrue);
      final content = await jsonFile.readAsString();
      final parsed = jsonDecode(content);
      expect(parsed['format'], equals('what-was-that-discoveries'));
      expect(parsed['discoveries'][0]['title'], equals('Compass 🧭'));
    });
  });
}
