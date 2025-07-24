import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/guardian_provider.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/location_service.dart';
import 'core/constants/app_constants.dart';

class TuitionHelperApp extends StatelessWidget {
  const TuitionHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GuardianProvider()),
        // Add other providers here as we create them
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,

            // Routing
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,

            // Localization
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('bn', 'BD'), // Bengali
            ],

            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(themeProvider.fontSizeScale),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class AppInitializer {
  static Future<void> initialize() async {
    try {
      // Initialize storage service
      final storageService = StorageService();
      await storageService.initHive();
      debugPrint('Storage service initialized successfully');

      // Initialize notification service
      try {
        final notificationService = NotificationService();
        await notificationService.initialize();
        debugPrint('Notification service initialized successfully');
      } catch (e) {
        debugPrint('Notification service initialization failed: $e');
      }

      // Initialize location service
      try {
        final locationService = LocationService();
        await locationService.initialize();
        debugPrint('Location service initialized successfully');
      } catch (e) {
        debugPrint('Location service initialization failed: $e');
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      rethrow;
    }
  }
}
