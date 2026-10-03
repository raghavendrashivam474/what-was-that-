import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'features/discovery/data/datasources/discovery_database.dart';
import 'features/discovery/data/datasources/image_storage_service.dart';
import 'features/discovery/data/repositories/drift_discovery_repository.dart';
import 'features/discovery/domain/repositories/discovery_repository.dart';
import 'features/identification/data/datasources/vision_image_identifier.dart';
import 'features/identification/domain/repositories/image_identifier.dart';
import 'features/identification/presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();

  final database = AppDatabase();
  final imageStorageService = LocalImageStorageService();
  final discoveryRepository = DriftDiscoveryRepository(
    database: database,
    imageStorageService: imageStorageService,
  );
  final imageIdentifier = VisionImageIdentifier();

  runApp(
    WhatWasThatApp(
      identifier: imageIdentifier,
      repository: discoveryRepository,
    ),
  );
}

class WhatWasThatApp extends StatelessWidget {
  final ImageIdentifier identifier;
  final DiscoveryRepository? repository;

  const WhatWasThatApp({
    super.key,
    required this.identifier,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'What Was That?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(
        identifier: identifier,
        repository: repository,
      ),
    );
  }
}
