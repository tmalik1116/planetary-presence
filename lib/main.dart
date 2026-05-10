import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'config/app_theme.dart';
import 'services/logger_service.dart';
import 'widgets/auth_gate.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
const _themePrefKey = 'theme_mode';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger.init();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString(_themePrefKey);
  if (savedTheme == 'light') {
    themeModeNotifier.value = ThemeMode.light;
  } else if (savedTheme == 'dark') {
    themeModeNotifier.value = ThemeMode.dark;
  }
  runApp(const PlanetaryPresenceApp());
}

class PlanetaryPresenceApp extends StatelessWidget {
  const PlanetaryPresenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Planetary Presence',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const AuthGate(),
        );
      },
    );
  }
}
