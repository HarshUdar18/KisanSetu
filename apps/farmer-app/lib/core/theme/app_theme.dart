import 'package:flutter/material.dart';

/// Exact Material 3 color tokens from Stitch `farmer app ui/kisan_setu/DESIGN.md`.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF005128);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF146B3A);
  static const Color onPrimaryContainer = Color(0xFF97E9AB);
  static const Color primaryFixed = Color(0xFFA2F5B6);
  static const Color primaryFixedDim = Color(0xFF87D89C);
  static const Color onPrimaryFixed = Color(0xFF00210D);

  static const Color secondary = Color(0xFF006D36);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF8FF9AA);
  static const Color onSecondaryContainer = Color(0xFF00743A);

  static const Color tertiary = Color(0xFF584200);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF755900);
  static const Color onTertiaryContainer = Color(0xFFFFD158);
  static const Color tertiaryFixed = Color(0xFFFFDF95);
  static const Color tertiaryFixedDim = Color(0xFFF4BF1B);
  static const Color harvestGold = Color(0xFFFFC928);
  static const Color onTertiaryFixed = Color(0xFF251A00);

  static const Color surface = Color(0xFFF2FCF2);
  static const Color background = Color(0xFFF2FCF2);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFECF6EC);
  static const Color surfaceContainer = Color(0xFFE6F1E7);
  static const Color surfaceContainerHigh = Color(0xFFE1EBE1);
  static const Color surfaceContainerHighest = Color(0xFFDBE5DB);

  static const Color onSurface = Color(0xFF151E18);
  static const Color onSurfaceVariant = Color(0xFF3F4940);
  static const Color outline = Color(0xFF6F7A70);
  static const Color outlineVariant = Color(0xFFBFC9BE);
  static const Color cardBorder = Color(0xFFE5ECE6);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color success = Color(0xFF25834A);
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double gutterMobile = 12.0;
  static const double md = 16.0;
  static const double margin = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppRadius {
  AppRadius._();
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double sheet = 24.0;
  static const double full = 9999.0;
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get level1 => [
        BoxShadow(
          color: const Color(0xFF142819).withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get level2 => [
        BoxShadow(
          color: const Color(0xFF142819).withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get level3 => [
        BoxShadow(
          color: const Color(0xFF142819).withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}

class AppTheme {
  static const String fontFamily = 'Inter';

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        height: 44 / 36,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: _textTheme(AppColors.onSurface, AppColors.onSurfaceVariant),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.secondaryContainer.withValues(alpha: 0.45),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: fontFamily,
            fontSize: 11,
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            color: sel ? AppColors.primary : AppColors.onSurfaceVariant,
          );
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkSurface = Color(0xFF101813);
    const darkCard = Color(0xFF19241D);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: darkSurface,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryFixedDim,
        secondary: AppColors.secondaryContainer,
        surface: darkSurface,
        onSurface: Color(0xFFE9F3E9),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: Color(0xFF29382E)),
        ),
      ),
    );
  }
}
