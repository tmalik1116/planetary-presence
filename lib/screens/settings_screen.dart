import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_theme.dart';
import '../main.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _questUpdates = true;
  bool _leaderboardChanges = true;
  bool _newQuestsNearby = true;

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.dmTextSecondary : AppColors.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userEmail = AuthService.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Appearance section
          _sectionHeader('APPEARANCE', isDark),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeModeNotifier,
            builder: (context, themeMode, _) {
              return ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: themeMode,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      themeModeNotifier.value = mode;
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setString('theme_mode', mode == ThemeMode.light
                            ? 'light'
                            : mode == ThemeMode.dark
                                ? 'dark'
                                : 'system');
                      });
                    }
                  },
                ),
              );
            },
          ),

          const Divider(),

          // Account section
          _sectionHeader('ACCOUNT', isDark),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showComingSoon,
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showComingSoon,
          ),
          ListTile(
            leading: const Icon(Icons.location_city_outlined),
            title: const Text('Home City'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showComingSoon,
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: userEmail.isNotEmpty ? Text(userEmail) : null,
          ),

          const Divider(),

          // Notifications section
          _sectionHeader('NOTIFICATIONS', isDark),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Quest Updates'),
            value: _questUpdates,
            onChanged: (val) => setState(() => _questUpdates = val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.leaderboard_outlined),
            title: const Text('Leaderboard Changes'),
            value: _leaderboardChanges,
            onChanged: (val) => setState(() => _leaderboardChanges = val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.place_outlined),
            title: const Text('New Quests Nearby'),
            value: _newQuestsNearby,
            onChanged: (val) => setState(() => _newQuestsNearby = val),
          ),

          const Divider(),

          // About section
          _sectionHeader('ABOUT', isDark),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showComingSoon,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
