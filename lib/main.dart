import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF7C3AED); // Violet
    const secondaryColor = Color(0xFF06B6D4); // Cyan
    const tertiaryColor = Color(0xFF10B981); // Emerald
    const errorColor = Color(0xFFEF4444); // Red
    const bgColor = Color(0xFF0A0F1E); // Deep navy

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.windows: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.linux: FadeThroughPageTransitionsBuilder(),
          },
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: primaryColor,
          onPrimary: Colors.white,
          secondary: secondaryColor,
          onSecondary: Colors.black,
          error: errorColor,
          onError: Colors.white,
          surface: bgColor,
          onSurface: Colors.white,
          primaryContainer: const Color(0xFF2D1B69),
          onPrimaryContainer: Colors.white,
          secondaryContainer: const Color(0xFF083344),
          onSecondaryContainer: Colors.white,
          tertiaryContainer: const Color(0xFF064E3B),
          onTertiaryContainer: Colors.white,
          errorContainer: const Color(0xFF4A0014),
          onErrorContainer: Colors.white,
          tertiary: tertiaryColor,
          onTertiary: Colors.white,
          surfaceContainerHighest: const Color(0xFF1A1F35),
        ),
        scaffoldBackgroundColor: bgColor,
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF141929),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.all(8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: secondaryColor,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
