import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finance_daily_digest/presentation/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: FinanceDailyDigestApp(),
      ),
    );

    // Verify that the app title is displayed.
    expect(find.text('Finance Daily Digest'), findsOneWidget);
    expect(find.text('Architecture setup complete ✓'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsOneWidget);
  });
}
