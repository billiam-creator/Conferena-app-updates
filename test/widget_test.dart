import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketkona/main.dart';
import 'package:ticketkona/services/settings_manager.dart';

void main() {
  testWidgets('App launches without error', (WidgetTester tester) async {
    // Provide the required initialSettings argument
    await tester.pumpWidget(MyApp(
      initialSettings: const AppSettings(
        soundEnabled: true,
        vibrationEnabled: true,
        themeString: 'system',
      ),
    ));

    // Just verify the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}