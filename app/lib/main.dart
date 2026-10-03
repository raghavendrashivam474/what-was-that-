import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'features/identification/data/datasources/vision_image_identifier.dart';
import 'features/identification/presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();

  final imageIdentifier = VisionImageIdentifier();

  runApp(WhatWasThatApp(identifier: imageIdentifier));
}

class WhatWasThatApp extends StatelessWidget {
  final VisionImageIdentifier identifier;

  const WhatWasThatApp({
    super.key,
    required this.identifier,
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
      home: HomeScreen(identifier: identifier),
    );
  }
}
