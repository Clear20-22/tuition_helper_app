import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../core/themes/light_theme.dart';
import '../core/themes/dark_theme.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  static const String _themeKey = 'app_theme_mode';
  static const String _primaryColorKey = 'primary_color';
  static const String _fontSizeKey = 'font_size_scale';

  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = const Color(0xFF2E7D5F);
  double _fontSizeScale = 1.0;

  // Getters
  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  double get fontSizeScale => _fontSizeScale;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  bool get isLightMode => !isDarkMode;

  // Theme data
  ThemeData get lightTheme => AppTheme.lightTheme.copyWith(
    colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
      primary: _primaryColor,
    ),
    textTheme: _scaledTextTheme(AppTheme.lightTheme.textTheme),
  );

  ThemeData get darkTheme => DarkAppTheme.darkTheme.copyWith(
    colorScheme: DarkAppTheme.darkTheme.colorScheme.copyWith(
      primary: _primaryColor,
    ),
    textTheme: _scaledTextTheme(DarkAppTheme.darkTheme.textTheme),
  );

  // Scale text theme based on font size scale
  TextTheme _scaledTextTheme(TextTheme baseTheme) {
    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        fontSize: (baseTheme.displayLarge?.fontSize ?? 57) * _fontSizeScale,
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        fontSize: (baseTheme.displayMedium?.fontSize ?? 45) * _fontSizeScale,
      ),
      displaySmall: baseTheme.displaySmall?.copyWith(
        fontSize: (baseTheme.displaySmall?.fontSize ?? 36) * _fontSizeScale,
      ),
      headlineLarge: baseTheme.headlineLarge?.copyWith(
        fontSize: (baseTheme.headlineLarge?.fontSize ?? 32) * _fontSizeScale,
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        fontSize: (baseTheme.headlineMedium?.fontSize ?? 28) * _fontSizeScale,
      ),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
        fontSize: (baseTheme.headlineSmall?.fontSize ?? 24) * _fontSizeScale,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontSize: (baseTheme.titleLarge?.fontSize ?? 22) * _fontSizeScale,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        fontSize: (baseTheme.titleMedium?.fontSize ?? 16) * _fontSizeScale,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        fontSize: (baseTheme.titleSmall?.fontSize ?? 14) * _fontSizeScale,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        fontSize: (baseTheme.bodyLarge?.fontSize ?? 16) * _fontSizeScale,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        fontSize: (baseTheme.bodyMedium?.fontSize ?? 14) * _fontSizeScale,
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        fontSize: (baseTheme.bodySmall?.fontSize ?? 12) * _fontSizeScale,
      ),
      labelLarge: baseTheme.labelLarge?.copyWith(
        fontSize: (baseTheme.labelLarge?.fontSize ?? 14) * _fontSizeScale,
      ),
      labelMedium: baseTheme.labelMedium?.copyWith(
        fontSize: (baseTheme.labelMedium?.fontSize ?? 12) * _fontSizeScale,
      ),
      labelSmall: baseTheme.labelSmall?.copyWith(
        fontSize: (baseTheme.labelSmall?.fontSize ?? 11) * _fontSizeScale,
      ),
    );
  }

  // Initialize theme
  Future<void> initialize() async {
    await _loadThemeMode();
    await _loadPrimaryColor();
    await _loadFontSizeScale();
    _updateSystemUIOverlay();
  }

  // Load theme mode from storage
  Future<void> _loadThemeMode() async {
    try {
      final themeModeString = await _storageService.getSetting<String>(_themeKey);
      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  // Load primary color from storage
  Future<void> _loadPrimaryColor() async {
    try {
      final colorValue = await _storageService.getSetting<int>(_primaryColorKey);
      if (colorValue != null) {
        _primaryColor = Color(colorValue);
      }
    } catch (e) {
      debugPrint('Error loading primary color: $e');
    }
  }

  // Load font size scale from storage
  Future<void> _loadFontSizeScale() async {
    try {
      final fontSizeScale = await _storageService.getSetting<double>(_fontSizeKey);
      if (fontSizeScale != null) {
        _fontSizeScale = fontSizeScale;
      }
    } catch (e) {
      debugPrint('Error loading font size scale: $e');
    }
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _storageService.saveSetting(_themeKey, mode.toString());
      _updateSystemUIOverlay();
      notifyListeners();
    }
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  // Set to light mode
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  // Set to dark mode
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  // Set to system mode
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }

  // Set primary color
  Future<void> setPrimaryColor(Color color) async {
    if (_primaryColor != color) {
      _primaryColor = color;
      await _storageService.saveSetting(_primaryColorKey, color.value);
      notifyListeners();
    }
  }

  // Set font size scale
  Future<void> setFontSizeScale(double scale) async {
    if (_fontSizeScale != scale) {
      _fontSizeScale = scale.clamp(0.8, 1.4);
      await _storageService.saveSetting(_fontSizeKey, _fontSizeScale);
      notifyListeners();
    }
  }

  // Reset to default theme
  Future<void> resetToDefault() async {
    await setThemeMode(ThemeMode.system);
    await setPrimaryColor(const Color(0xFF2E7D5F));
    await setFontSizeScale(1.0);
  }

  // Update system UI overlay style based on current theme
  void _updateSystemUIOverlay() {
    final statusBarBrightness = isDarkMode ? Brightness.light : Brightness.dark;
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: statusBarBrightness,
        statusBarIconBrightness: statusBarBrightness,
        systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: statusBarBrightness,
      ),
    );
  }

  // Get predefined color options
  List<Color> get colorOptions => [
    const Color(0xFF2E7D5F), // Default green
    const Color(0xFF1976D2), // Blue
    const Color(0xFF7B1FA2), // Purple
    const Color(0xFFD32F2F), // Red
    const Color(0xFFFF8F00), // Orange
    const Color(0xFF388E3C), // Green
    const Color(0xFF0097A7), // Cyan
    const Color(0xFF5D4037), // Brown
    const Color(0xFF455A64), // Blue Grey
    const Color(0xFF5E35B1), // Deep Purple
  ];

  // Get font size scale options
  List<Map<String, dynamic>> get fontSizeOptions => [
    {'label': 'Small', 'value': 0.8},
    {'label': 'Normal', 'value': 1.0},
    {'label': 'Large', 'value': 1.2},
    {'label': 'Extra Large', 'value': 1.4},
  ];

  // Get current font size label
  String get currentFontSizeLabel {
    for (final option in fontSizeOptions) {
      if ((option['value'] as double) == _fontSizeScale) {
        return option['label'] as String;
      }
    }
    return 'Custom';
  }

  // Get theme mode display name
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Export theme settings
  Map<String, dynamic> exportSettings() {
    return {
      'themeMode': _themeMode.toString(),
      'primaryColor': _primaryColor.value,
      'fontSizeScale': _fontSizeScale,
    };
  }

  // Import theme settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      if (settings['themeMode'] != null) {
        final themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == settings['themeMode'],
          orElse: () => ThemeMode.system,
        );
        await setThemeMode(themeMode);
      }

      if (settings['primaryColor'] != null) {
        await setPrimaryColor(Color(settings['primaryColor'] as int));
      }

      if (settings['fontSizeScale'] != null) {
        await setFontSizeScale(settings['fontSizeScale'] as double);
      }
    } catch (e) {
      debugPrint('Error importing theme settings: $e');
    }
  }

  // Check if using custom theme
  bool get isCustomTheme {
    return _primaryColor != const Color(0xFF2E7D5F) || 
           _fontSizeScale != 1.0;
  }

  // Get theme brightness
  Brightness get brightness {
    return isDarkMode ? Brightness.dark : Brightness.light;
  }

  // Get app bar theme
  AppBarTheme get appBarTheme {
    return isDarkMode ? darkTheme.appBarTheme : lightTheme.appBarTheme;
  }

  // Get color scheme
  ColorScheme get colorScheme {
    return isDarkMode ? darkTheme.colorScheme : lightTheme.colorScheme;
  }

  // Get text theme
  TextTheme get textTheme {
    return isDarkMode ? darkTheme.textTheme : lightTheme.textTheme;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
