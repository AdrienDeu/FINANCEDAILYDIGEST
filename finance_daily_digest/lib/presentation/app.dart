import 'package:flutter/material.dart';

import 'screens/main_screen.dart';

class FinanceDailyDigestApp extends StatelessWidget {
  const FinanceDailyDigestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Daily Digest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
