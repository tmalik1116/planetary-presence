import 'dart:io';
import 'package:flutter/material.dart';
import '../services/logger_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'View Logs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Log file path:'),
            const SizedBox(height: 4),
            SelectableText(
              AppLogger.logFilePath.isEmpty
                  ? 'Not initialized'
                  : AppLogger.logFilePath,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.terminal),
              label: const Text('Print logs to console'),
              onPressed: () {
                final path = AppLogger.logFilePath;
                if (path.isEmpty) {
                  AppLogger.w('Log file path not initialized');
                  return;
                }
                final file = File(path);
                if (!file.existsSync()) {
                  AppLogger.w('Log file does not exist yet: $path');
                  return;
                }
                final contents = file.readAsStringSync();
                AppLogger.d(contents);
              },
            ),
          ],
        ),
      ),
    );
  }
}
