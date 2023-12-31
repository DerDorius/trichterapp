import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trichterapp/src/dart/trichter_manager.dart';
import 'package:trichterapp/src/dart/websocketmanager.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();
  WebSocketManager().initializeWebSocket();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(DevicePreview(
      enabled: false,
      builder: (context) {
        return ChangeNotifierProvider(
            create: (context) => TrichterManager(),
            child: MyApp(settingsController: settingsController));
      }));
}
