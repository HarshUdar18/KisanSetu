import 'package:flutter/material.dart';

/// Exact Material 3 color tokens from Stitch `kisan_setu/DESIGN.md` & `code.html`.
class AppColors {
  AppColors._();

  // Brand & Primary
  static const Color primary = Color(0xFF005128);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF146B3A);
  static const Color onPrimaryContainer = Color(0xFF97E9AB);
  static const Color primaryFixed = Color(0xFFA2F5B6);
  static const Color primaryFixedDim = Color(0xFF87D89C);
  static const Color onPrimaryFixed = Color(0xFF00210D);
  static const Color onPrimaryFixedVariant = Color(0xFF005229);
  static const Color inversePrimary = Color(0xFF87D89C);

  // Secondary
  static const Color secondary = Color(0xFF006D36);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF8FF9AA);
  static const Color onSecondaryContainer = Color(0xFF00743A);
  static const Color secondaryFixed = Color(0xFF8FF9AA);
  static const Color secondaryFixedDim = Color(0xFF73DC90);
  static const Color onSecondaryFixed = Color(0xFF00210C);

  // Tertiary / Harvest Gold
  static const Color tertiary = Color(0xFF584200);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF755900);
  static const Color onTertiaryContainer = Color(0xFFFFD158);
  static const Color tertiaryFixed = Color(0xFFFFDF95);
  static const Color tertiaryFixedDim = Color(0xFFF4BF1B);
  static const Color harvestGold = Color(0xFFFFC928);
  static const Color onTertiaryFixed = Color(0xFF251A00);
  static const Color onTertiaryFixedVariant = Color(0xFF594400);

  // Surfaces & Backgrounds
  static const Color surface = Color(0xFFF2FCF2);
  static const Color background = Color(0xFFF2FCF2);
  static const Color surfaceDim = Color(0xFFD2DDD3);
  static const Color surfaceBright = Color(0xFFF2FCF2);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFECF6EC);
  static const Color surfaceContainer = Color(0xFFE6F1E7);
  static const Color surfaceContainerHigh = Color(0xFFE1EBE1);
  static const Color surfaceContainerHighest = Color(0xFFDBE5DB);
  static const Color surfaceVariant = Color(0xFFDBE5DB);
  static const Color surfaceTint = Color(0xFF166C3B);

  // Text & Outlines
  static const Color onSurface = Color(0xFF151E18);
  static const Color onBackground = Color(0xFF151E18);
  static const Color onSurfaceVariant = Color(0xFF3F4940);
  static const Color outline = Color(0xFF6F7A70);
  static const Color outlineVariant = Color(0xFFBFC9BE);
  static const Color cardBorder = Color(0xFFE5ECE6);
  static const Color inverseSurface = Color(0xFF29332C);
  static const Color inverseOnSurface = Color(0xFFE9F3E9);

  // Semantic
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color success = Color(0xFF25834A);
  static const Color warning = Color(0xFFF4BF1B);
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

  static TextTheme _buildTextTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        height: 44 / 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 36,
        color: primaryText,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 28,
        color: primaryText,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: primaryText,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: primaryText,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.01 * 16,
        color: primaryText,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.015 * 14,
        color: primaryText,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.02 * 12,
        color: secondaryText,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01 * 14,
        color: primaryText,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.04 * 12,
        color: primaryText,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05 * 11,
        color: secondaryText,
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
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
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: _buildTextTheme(AppColors.onSurface, AppColors.onSurfaceVariant),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
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
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: const BorderSide(color: AppColors.outlineVariant, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: AppColors.outline,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.secondaryContainer.withValues(alpha: 0.45),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: fontFamily,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFF0F4F1),
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkSurface = Color(0xFF101813);
    const darkCard = Color(0xFF19241D);
    const darkText = Color(0xFFE9F3E9);
    const darkSubtext = Color(0xFFBFC9BE);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryFixedDim,
        onPrimary: AppColors.onPrimaryFixed,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondaryFixedDim,
        onSecondary: AppColors.onSecondaryFixed,
        tertiary: AppColors.tertiaryFixedDim,
        onTertiary: AppColors.onTertiaryFixed,
        surface: darkSurface,
        onSurface: darkText,
        onSurfaceVariant: darkSubtext,
        surfaceContainerLowest: darkCard,
        surfaceContainerLow: Color(0xFF1E2B22),
        error: AppColors.errorContainer,
      ),
      scaffoldBackgroundColor: darkSurface,
      textTheme: _buildTextTheme(darkText, darkSubtext),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: Color(0xFF29382E), width: 1),
        ),
      ),
    );
  }
}
