import 'package:flutter/material.dart';

class AppThemeBundle {
  const AppThemeBundle({required this.light, required this.dark});
  final ThemeData light;
  final ThemeData dark;
}

class AppTheme {
  static AppThemeBundle build() {
    const seed = Color(0xFF7C5CFF); // young violet
    const secondary = Color(0xFF2DE2E6); // neon cyan
    const tertiary = Color(0xFFFF4D8D); // punch pink

    final lightScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ).copyWith(
      secondary: secondary,
      tertiary: tertiary,
    );

    final darkScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: secondary,
      tertiary: tertiary,
    );

    ThemeData base(ColorScheme scheme) => ThemeData(
          useMaterial3: true,
          colorScheme: scheme,
          visualDensity: VisualDensity.standard,
          scaffoldBackgroundColor: scheme.surface,
          dividerColor: scheme.outlineVariant,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: scheme.surface,
            foregroundColor: scheme.onSurface,
            elevation: 0,
            centerTitle: false,
          ),
          navigationRailTheme: NavigationRailThemeData(
            backgroundColor: scheme.surface,
            selectedIconTheme: IconThemeData(color: scheme.primary),
            selectedLabelTextStyle: TextStyle(color: scheme.primary),
          ),
        );

    return AppThemeBundle(light: base(lightScheme), dark: base(darkScheme));
  }
}

