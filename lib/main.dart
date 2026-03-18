// =============================================================================
// Flutter Assignment #1 — Todo List App
// Author  : Abdul Hadi
// Email   : ah912425@gmail.com
// Course  : Flutter Training
// =============================================================================

import 'package:flutter/material.dart';
import 'screens/todo_list_screen.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const TodoListScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    const seed = Color(0xFF4F6AF5); // indigo-blue accent
    final cs = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const seed = Color(0xFF6B84F8);
    final cs = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
