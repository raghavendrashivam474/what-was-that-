import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_was_that/features/identification/domain/entities/identification_result.dart';
import 'package:what_was_that/features/identification/domain/repositories/image_identifier.dart';
import 'package:what_was_that/features/identification/presentation/screens/home_screen.dart';
import 'package:what_was_that/features/identification/presentation/screens/result_screen.dart';

class FakeImageIdentifier implements ImageIdentifier {
  @override
  Future<IdentificationResult> identify(String imagePath) async {
    return const IdentificationResult(
      identifiable: true,
      title: 'Mock Item',
      explanation: 'Mock Explanation',
      confidence: IdentificationConfidence.high,
    );
  }
}

void main() {
  testWidgets('HomeScreen renders title and capture action', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(identifier: FakeImageIdentifier()),
      ),
    );

    expect(find.text('WHAT WAS THAT?'), findsOneWidget);
    expect(find.text('What is this?'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });

  testWidgets('ResultScreen renders identified result and confidence badge', (WidgetTester tester) async {
    const result = IdentificationResult(
      identifiable: true,
      title: 'USB-C Cable',
      explanation: 'A cable used for data and charging.',
      confidence: IdentificationConfidence.high,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: ResultScreen(
          imagePath: 'dummy_path.jpg',
          result: result,
        ),
      ),
    );

    expect(find.text('USB-C Cable'), findsOneWidget);
    expect(find.text('A cable used for data and charging.'), findsOneWidget);
    expect(find.text('Confidence: High'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('ResultScreen renders unidentifiable state correctly', (WidgetTester tester) async {
    final result = IdentificationResult.unidentifiable();

    await tester.pumpWidget(
      MaterialApp(
        home: ResultScreen(
          imagePath: 'dummy_path.jpg',
          result: result,
        ),
      ),
    );

    expect(find.text("I couldn't identify this confidently."), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });
}
