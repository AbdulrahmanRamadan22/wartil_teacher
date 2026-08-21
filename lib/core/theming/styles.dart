import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'font_weight.dart';
import 'app_dimensions.dart';

class TextStyles {
  TextStyles._();

  // ── Headlines ─────────────────────────────────────────────────────────────
  static const TextStyle font32BoldTextPrimary = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 32,
    fontWeight: AppFontWeight.bold,
    color: ColorsManager.textPrimaryColor,
  );

  static const TextStyle font28BoldTextPrimary = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 28,
    fontWeight: AppFontWeight.bold,
    color: ColorsManager.textPrimaryColor,
  );

  static const TextStyle font24SemiBoldTextPrimary = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 24,
    fontWeight: AppFontWeight.semiBold,
    color: ColorsManager.textPrimaryColor,
  );

  // ── Body ──────────────────────────────────────────────────────────────────
  static const TextStyle font20MediumTextPrimary = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 20,
    fontWeight: AppFontWeight.medium,
    color: ColorsManager.textPrimaryColor,
  );

  static const TextStyle font18MediumTextPrimary = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 18,
    fontWeight: AppFontWeight.medium,
    color: ColorsManager.textPrimaryColor,
  );

  static const TextStyle font16RegularTextPrimary = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: AppFontWeight.regular,
    color: ColorsManager.textPrimaryColor,
  );

  static const TextStyle font14RegularTextSecondary = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: AppFontWeight.regular,
    color: ColorsManager.textSecondaryColor,
  );

  // ── Small ─────────────────────────────────────────────────────────────────
  static const TextStyle font12RegularTextSecondary = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    fontWeight: AppFontWeight.regular,
    color: ColorsManager.textSecondaryColor,
  );

  static const TextStyle font16SemiBoldWhite = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: AppFontWeight.semiBold,
    color: Colors.white,
  );

  // ── Special ───────────────────────────────────────────────────────────────
  static const TextStyle hint = TextStyle(
    fontFamily: 'Cairo',
    fontSize: AppDimensions.fontM,
    fontWeight: AppFontWeight.regular,
    color: ColorsManager.textHintColor,
  );

  static const TextStyle error = TextStyle(
    fontFamily: 'Cairo',
    fontSize: AppDimensions.fontM,
    fontWeight: AppFontWeight.regular,
    color: ColorsManager.errorColor,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: AppDimensions.fontRegular,
    fontWeight: AppFontWeight.semiBold,
    color: Colors.white,
    letterSpacing: 0.5,
  );
}

class AppStyles {
  AppStyles._();

  // ── Backwards-compatible getters ──────────────────────────────────────────
  static const TextStyle headline1 = TextStyles.font32BoldTextPrimary;
  static const TextStyle subtitle2 = TextStyles.font16SemiBoldWhite;

  // ── Input border helper ───────────────────────────────────────────────────
  static OutlineInputBorder _inputBorder(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        borderSide: BorderSide(color: color, width: width),
      );

  // ── Full Theme — matches wrattel-development quality ──────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: ColorsManager.backgroundColor,

    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorsManager.primaryColor,
      brightness: Brightness.light,
      primary: ColorsManager.primaryColor,
      secondary: ColorsManager.secondaryColor,
      tertiary: ColorsManager.accentColor,
      error: ColorsManager.errorColor,
      surface: ColorsManager.surfaceColor,
      surfaceContainerHighest: ColorsManager.backgroundColor,
    ),

    // ── Smooth transitions: FadeUpwards on Android, Cupertino on iOS ────────
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),

    // ── AppBar: clean WHITE with dark text (not colored!) ────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: ColorsManager.textPrimaryColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      toolbarHeight: AppDimensions.appBarHeight,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: AppDimensions.fontL,
        fontWeight: AppFontWeight.semiBold,
        color: ColorsManager.textPrimaryColor,
      ),
      iconTheme: IconThemeData(
        color: ColorsManager.textPrimaryColor,
        size: AppDimensions.iconM,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),

    // ── Bottom Nav: white bg, teal selected, grey unselected ─────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: ColorsManager.primaryColor,
      unselectedItemColor: ColorsManager.textSecondaryColor,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: AppDimensions.fontS,
        fontWeight: AppFontWeight.semiBold,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: AppDimensions.fontS,
        fontWeight: AppFontWeight.regular,
      ),
      selectedIconTheme: IconThemeData(
        size: AppDimensions.bottomNavIconSelected,
        color: ColorsManager.primaryColor,
      ),
      unselectedIconTheme: IconThemeData(
        size: AppDimensions.bottomNavIconUnselected,
        color: ColorsManager.textSecondaryColor,
      ),
    ),

    // ── Bottom Sheet ──────────────────────────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),

    // ── Cards: zero elevation, consistent radius ───────────────────────────────
    cardTheme: const CardThemeData(
      color: ColorsManager.surfaceColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusM)),
      ),
    ),

    // ── Elevated Button ───────────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(ColorsManager.primaryColor),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(0),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        minimumSize: WidgetStateProperty.all(
          const Size(0, AppDimensions.buttonHeightM),
        ),
        overlayColor: WidgetStateProperty.all(
          Colors.white.withValues(alpha: 0.12),
        ),
        textStyle: WidgetStateProperty.all(TextStyles.buttonMedium),
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusS)),
          ),
        ),
      ),
    ),

    // ── Outlined Button ───────────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorsManager.primaryColor,
        minimumSize: const Size(0, AppDimensions.buttonHeightM),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusS)),
        ),
        side: const BorderSide(
          color: ColorsManager.primaryColor,
          width: AppDimensions.borderMedium,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.buttonPaddingHL,
          vertical: AppDimensions.buttonPaddingVM,
        ),
      ),
    ),

    // ── Text Button ───────────────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorsManager.primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusS)),
        ),
      ),
    ),

    // ── Input Decoration ──────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorsManager.surfaceColor,
      hintStyle: TextStyles.hint,
      errorStyle: TextStyles.error,
      prefixIconColor: ColorsManager.iconSecondary,
      suffixIconColor: ColorsManager.iconSecondary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.inputPaddingH,
        vertical: AppDimensions.inputPaddingV,
      ),
      border: _inputBorder(ColorsManager.borderColor, AppDimensions.borderNormal),
      enabledBorder: _inputBorder(ColorsManager.borderColor, AppDimensions.borderNormal),
      focusedBorder: _inputBorder(ColorsManager.primaryColor, AppDimensions.borderMedium),
      errorBorder: _inputBorder(ColorsManager.errorColor, AppDimensions.borderNormal),
      focusedErrorBorder: _inputBorder(ColorsManager.errorColor, AppDimensions.borderMedium),
    ),

    // ── Divider ───────────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: ColorsManager.dividerColor,
      thickness: AppDimensions.dividerThickness,
      space: AppDimensions.dividerThickness,
      indent: AppDimensions.dividerIndent,
      endIndent: AppDimensions.dividerIndent,
    ),

    // ── Icon ──────────────────────────────────────────────────────────────────
    iconTheme: const IconThemeData(
      color: ColorsManager.iconPrimary,
      size: AppDimensions.iconM,
    ),

    // ── List Tile ─────────────────────────────────────────────────────────────
    listTileTheme: const ListTileThemeData(
      iconColor: ColorsManager.iconPrimary,
      textColor: ColorsManager.textPrimaryColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusS)),
      ),
    ),

    // ── Chip ──────────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: ColorsManager.surfaceColor,
      disabledColor: ColorsManager.borderColor,
      selectedColor: ColorsManager.primaryColor.withValues(alpha: 0.15),
      labelStyle: TextStyles.font14RegularTextSecondary,
      padding: const EdgeInsets.all(AppDimensions.paddingS),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusS)),
      ),
    ),

    // ── Dialog ────────────────────────────────────────────────────────────────
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: AppDimensions.elevationHigh,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: AppDimensions.fontH6,
        fontWeight: AppFontWeight.semiBold,
        color: ColorsManager.textPrimaryColor,
      ),
      contentTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: AppDimensions.fontRegular,
        fontWeight: AppFontWeight.regular,
        color: ColorsManager.textPrimaryColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusL)),
      ),
    ),

    // ── Snackbar ──────────────────────────────────────────────────────────────
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: ColorsManager.textPrimaryColor,
      contentTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: AppDimensions.fontRegular,
        color: Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusS)),
      ),
    ),

    // ── Full TextTheme ────────────────────────────────────────────────────────
    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontFamily: 'Cairo', fontSize: 48, fontWeight: AppFontWeight.bold,     color: ColorsManager.textPrimaryColor),
      displayMedium: TextStyle(fontFamily: 'Cairo', fontSize: 40, fontWeight: AppFontWeight.bold,     color: ColorsManager.textPrimaryColor),
      displaySmall:  TextStyle(fontFamily: 'Cairo', fontSize: 36, fontWeight: AppFontWeight.bold,     color: ColorsManager.textPrimaryColor),
      headlineLarge: TextStyle(fontFamily: 'Cairo', fontSize: 32, fontWeight: AppFontWeight.bold,     color: ColorsManager.textPrimaryColor, height: 1.3),
      headlineMedium:TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: AppFontWeight.bold,     color: ColorsManager.textPrimaryColor, height: 1.3),
      headlineSmall: TextStyle(fontFamily: 'Cairo', fontSize: 24, fontWeight: AppFontWeight.semiBold, color: ColorsManager.textPrimaryColor, height: 1.3),
      titleLarge:    TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: AppFontWeight.semiBold, color: ColorsManager.textPrimaryColor, height: 1.4),
      titleMedium:   TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: AppFontWeight.medium,   color: ColorsManager.textPrimaryColor, height: 1.4),
      titleSmall:    TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: AppFontWeight.medium,   color: ColorsManager.textPrimaryColor, height: 1.4),
      bodyLarge:     TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: AppFontWeight.regular,  color: ColorsManager.textPrimaryColor, height: 1.6),
      bodyMedium:    TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: AppFontWeight.regular,  color: ColorsManager.textPrimaryColor, height: 1.6),
      bodySmall:     TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: AppFontWeight.regular,  color: ColorsManager.textSecondaryColor, height: 1.6),
      labelLarge:    TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: AppFontWeight.medium,   height: 1.4, letterSpacing: 0.5),
      labelMedium:   TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: AppFontWeight.medium,   height: 1.4, letterSpacing: 0.5),
      labelSmall:    TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: AppFontWeight.medium,   color: ColorsManager.textSecondaryColor, height: 1.4, letterSpacing: 0.5),
    ),
  );
}
