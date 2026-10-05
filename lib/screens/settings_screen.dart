import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ==========================================================
  // LOAD SETTINGS
  // ==========================================================

  Future<void> _loadSettings() async {
    final prefs =
    await SharedPreferences.getInstance();

    final notificationsEnabled =
        prefs.getBool(
          'notifications_enabled',
        ) ??
            true;

    if (!mounted) {
      return;
    }

    setState(() {
      _notificationsEnabled =
          notificationsEnabled;
      _isLoading = false;
    });
  }

  // ==========================================================
  // NOTIFICATION SETTING
  // ==========================================================

  Future<void> _setNotifications(
      bool enabled,
      ) async {
    setState(() {
      _notificationsEnabled = enabled;
    });

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'notifications_enabled',
      enabled,
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettings.themeMode,
      builder: (
          context,
          themeMode,
          child,
          ) {
        final bool darkModeEnabled =
            themeMode == ThemeMode.dark;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          body: _isLoading
              ? const Center(
            child:
            CircularProgressIndicator(),
          )
              : ListView(
            padding:
            const EdgeInsets.all(16),
            children: [
              // ==================================================
              // PREFERENCES
              // ==================================================

              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Card(
                child: Column(
                  children: [
                    // --------------------------------------------
                    // NOTIFICATIONS
                    // --------------------------------------------

                    SwitchListTile(
                      secondary:
                      const Icon(
                        Icons
                            .notifications_outlined,
                      ),
                      title: const Text(
                        'Notifications',
                      ),
                      subtitle: const Text(
                        'Receive app notifications',
                      ),
                      value:
                      _notificationsEnabled,
                      onChanged:
                      _setNotifications,
                    ),

                    const Divider(
                      height: 1,
                    ),

                    // --------------------------------------------
                    // DARK MODE
                    // --------------------------------------------

                    SwitchListTile(
                      secondary:
                      const Icon(
                        Icons
                            .dark_mode_outlined,
                      ),
                      title: const Text(
                        'Dark Mode',
                      ),
                      subtitle: const Text(
                        'Use dark theme throughout the app',
                      ),
                      value:
                      darkModeEnabled,
                      onChanged:
                          (value) async {
                        await AppSettings
                            .setDarkMode(
                          value,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // ABOUT
              // ==================================================

              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Card(
                child: Column(
                  children: const [
                    ListTile(
                      leading: Icon(
                        Icons.train_outlined,
                      ),
                      title: Text(
                        'Local Rail',
                      ),
                      subtitle: Text(
                        'Mumbai suburban railway app',
                      ),
                    ),

                    Divider(
                      height: 1,
                    ),

                    ListTile(
                      leading: Icon(
                        Icons.info_outline,
                      ),
                      title: Text(
                        'App Version',
                      ),
                      subtitle: Text(
                        '1.0.0',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}