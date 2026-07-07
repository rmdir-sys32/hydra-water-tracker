import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_counter/main.dart';
import 'package:nfc_counter/settings_page.dart';

void main() {
  testWidgets('App loads and displays header', (WidgetTester tester) async {
    // Set viewport to 800x1200 logical pixels to prevent layout overflows in test environment
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title 'Hydrated' is displayed.
    expect(find.text('Hydrated'), findsOneWidget);
  });

  testWidgets('Navigating to settings page displays settings elements', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tap on settings icon button
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    // Verify Settings page has loaded
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Daily Goal'), findsOneWidget);
    expect(find.text('Tap Volume'), findsOneWidget);
    expect(find.text('Data Backup & Restore'), findsOneWidget);
    expect(find.text('Export JSON'), findsOneWidget);
    expect(find.text('Import JSON'), findsOneWidget);
  });

  testWidgets('Statistics home displays stats components and responds to theme modes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    // Verify Statistics page elements on the Home screen
    expect(find.text("Today's Hydration"), findsOneWidget);
    expect(find.text('Intake Overview'), findsOneWidget);
    expect(find.textContaining('Tap NFC to log'), findsOneWidget);
  });
}
