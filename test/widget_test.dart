import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:personal_memory_map/main.dart';
import 'package:personal_memory_map/providers/theme_provider.dart';
import 'package:personal_memory_map/providers/memory_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => MemoryProvider()),
        ],
        child: const PersonalMemoryMapApp(),
      ),
    );

    // Basic test
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
