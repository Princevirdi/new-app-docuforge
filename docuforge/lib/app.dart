import 'package:flutter/material.dart';

import 'features/home/home_screen.dart';

class DocuForgeApp extends StatelessWidget {
  const DocuForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF17213B);
    const accent = Color(0xFF536DFE);

    return MaterialApp(
      title: 'DocuForge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          primary: accent,
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: ink,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
          titleLarge: TextStyle(
            color: ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          bodyMedium: TextStyle(color: Color(0xFF737C92), fontSize: 14),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
