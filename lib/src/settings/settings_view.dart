import 'package:flutter/material.dart';
import 'package:trichterapp/src/devicediscovery/discovery_view.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            // Glue the SettingsController to the theme selection DropdownButton.
            //
            // When a user selects a theme from the dropdown list, the
            // SettingsController is updated, which rebuilds the MaterialApp.
            child: DropdownButton<ThemeMode>(
              // Read the selected themeMode from the controller
              value: controller.themeMode,
              // Call the updateThemeMode method any time the user selects a theme.
              onChanged: controller.updateThemeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark Theme'),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            //child: DeviceList(),
            child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.restorablePushNamed(
                    context,
                    DiscoveryPage.routeName,
                  );
                },
                icon: const Icon(Icons.bluetooth),
                // full width button
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
                label: const Text("Trichter Suchen")),
          ),
        ],
      ),
    );
  }
}
