import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../screens/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/guardians/guardian_add_screen.dart';
import '../screens/guardians/guardian_detail_screen.dart';
import '../screens/guardians/guardian_edit_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/guardians/guardians_screen.dart';
import '../screens/guardians/guardian_form_screen.dart';
import '../screens/guardians/guardian_detail_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/payments/payments_screen.dart';
import '../screens/maps/maps_screen.dart';
import '../screens/settings/settings_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case AppRoutes.guardians:
        return MaterialPageRoute(
          builder: (_) => const GuardiansScreen(),
          settings: settings,
        );

      case AppRoutes.guardiansAdd:
        return MaterialPageRoute(
          builder: (_) => const GuardianFormScreen(),
          settings: settings,
        );

      case AppRoutes.guardiansEdit:
        final guardianId = args?[AppRoutes.idParam] as String?;
        if (guardianId == null) {
          return _errorRoute('Guardian ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => GuardianFormScreen(guardianId: guardianId),
          settings: settings,
        );

      case AppRoutes.guardiansDetail:
        final guardianId = args?[AppRoutes.idParam] as String?;
        if (guardianId == null) {
          return _errorRoute('Guardian ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => GuardianDetailScreen(guardianId: guardianId),
          settings: settings,
        );

      case AppRoutes.calendar:
        return MaterialPageRoute(
          builder: (_) => const CalendarScreen(),
          settings: settings,
        );

      case AppRoutes.payments:
        return MaterialPageRoute(
          builder: (_) => const PaymentsScreen(),
          settings: settings,
        );

      case AppRoutes.maps:
        return MaterialPageRoute(
          builder: (_) => const MapsScreen(),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate back or to home
                },
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
