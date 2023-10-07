import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trichterapp/src/chat/chatview.dart';
import 'package:trichterapp/src/dart/websocketmanager.dart';
import 'package:trichterapp/src/devicediscovery/discovery_view.dart';
import 'package:trichterapp/src/trichtermain/scoreboard.dart';

import 'trichtermain/trichterdetail.dart';
import 'trichtermain/start_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<int, double> _liveTrichterData = {};
  StreamSubscription? subscription;
  WebSocketManager webSocketManager = WebSocketManager();

  @override
  void initState() {
    super.initState();

    // Subscribe to the message stream Für LiveTrichterData
    subscription = webSocketManager.messageStream.listen((message) {
      try {
        Map<String, dynamic> jsonMessage = jsonDecode(message);
        if (jsonMessage.containsKey("type")) {
          if (jsonMessage["type"] == "livetrichter") {
            List<Map<String, dynamic>> data = [
              {"t": jsonMessage["t"], "flow": jsonMessage["flow"]}
            ];

            _liveTrichterData.addEntries(data.map(
                (entry) => MapEntry<int, double>(entry["t"], entry["flow"])));
            setState(() {
              _liveTrichterData = _liveTrichterData;
            });
            //print(liveTrichterData.length.toString());
          } else if (jsonMessage["type"] == "resetlivetrichter") {
            _liveTrichterData.clear();
            setState(() {
              _liveTrichterData = _liveTrichterData;
            });
          }
        }
      } catch (e) {
        debugPrint('Error parsing json message: $message $e');
      }
    });
  }

  @override
  void dispose() {
    // Don't forget to unsubscribe from the message stream when the widget is disposed
    webSocketManager.messageStream.drain();
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: widget.settingsController);
                  case TrichterDetail.routeName:
                    return TrichterDetail(
                        liveTrichterData: _liveTrichterData, isLive: true);
                  case DiscoveryPage.routeName:
                    return const DiscoveryPage();
                  case ChatPage.routeName:
                    return const ChatPage();
                  case StartView.routeName:
                    return const StartView();
                  case Scoreboard.routeName:
                    return const Scoreboard();
                  default:
                    return const StartView();
                }
              },
            );
          },
        );
      },
    );
  }
}
