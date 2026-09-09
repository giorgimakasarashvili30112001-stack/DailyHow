import 'package:flutter/material.dart';
import 'screens/auth_gate.dart';
import 'theme/app_theme.dart';

class DailyHowApp extends StatelessWidget {
  const DailyHowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Daily How',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const AuthGate(),
    );
  }
}
