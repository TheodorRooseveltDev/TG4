import 'package:casino_clash/stats_analysis_check/stats_analysis_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/game_data_service.dart';
import 'services/game_save_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/prologue_screen.dart';
import 'screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await GameDataService.instance.loadGameData();
  await GameSaveService.instance.initialize();
  await NotificationService.instance.initialize();

  runApp(const ProviderScope(child: CasinoClashApp()));
}

class CasinoClashApp extends ConsumerWidget {
  const CasinoClashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Casino Clash: Trail of Chances',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red.shade900,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.red.shade900,
          secondary: Colors.red.shade700,
          surface: Colors.grey.shade900,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade900,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/prologue': (context) => const PrologueScreen(),
        '/map': (context) => const MapScreen(),
      },
      home: const StatsAnalysisCheck(),
    );
  }
}
