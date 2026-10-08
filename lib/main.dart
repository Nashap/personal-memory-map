import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_memory_map/core/theme/app_theme.dart';
import 'package:personal_memory_map/providers/memory_provider.dart';
import 'package:personal_memory_map/providers/theme_provider.dart';
import 'package:personal_memory_map/screens/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) {
          final provider = MemoryProvider();
          provider.loadMemories();
          return provider;
        }),
      ],
      child: const PersonalMemoryMapApp(),
    ),
  );
}

class PersonalMemoryMapApp extends StatelessWidget {
  const PersonalMemoryMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Personal Memory Map',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MainNavigation(),
        );
      },
    );
  }
}
