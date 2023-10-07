import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trichterapp/src/dart/trichter_manager.dart';
import 'package:trichterapp/src/dart/trichter_model.dart';
import 'package:trichterapp/src/widgets/connect_button.dart';
import 'package:trichterapp/src/widgets/trichter_summary_card.dart';
import 'package:http/http.dart' as http;

import '../settings/settings_view.dart';
import 'sample_item.dart';

/// Displays a list of SampleItems.
class StartView extends StatelessWidget {
  const StartView({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
  });

  static const routeName = '/';

  final List<SampleItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Trichter Liste'),
          actions: [
            const TrichterConnectButton(),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to the settings page. If the user leaves and returns
                // to the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(context, SettingsView.routeName);
              },
            ),
          ],
        ),

        // To work with lists that may contain a large number of items, it’s best
        // to use the ListView.builder constructor.
        //
        // In contrast to the default ListView constructor, which requires
        // building all Widgets up front, the ListView.builder constructor lazily
        // builds Widgets as they’re scrolled into view.
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<TrichterManager>(
                  builder: (context, trichterManager, child) {
                if (trichterManager.trichterList.isNotEmpty) {
                  TrichterModel lastTrichter =
                      trichterManager.trichterList.last;

                  return TrichterSummaryCard(
                    titleText: 'Letzter Trichter von ',
                    trichterName: lastTrichter.name,
                    dauerText: (lastTrichter.dauerInMs / 1000).toString() + "s",
                    maxDurchflussText:
                        "${lastTrichter.maxGeschwindigkeit} ml/s",
                    avgDurchflussText: "${lastTrichter.avgDurchfluss} ml/s",
                    mengeText: "${lastTrichter.mengeInLiter} Liter",
                  );
                }
                return TrichterSummaryCard(
                  titleText: 'Kein Trichter vorhanden ',
                  trichterName: "Verbindung?",
                  dauerText: '0 Sekunden',
                  maxDurchflussText: '0.0 ml/s',
                  avgDurchflussText: '0.0 ml/s',
                  mengeText: '0 Liter',
                );
              }),
              const SizedBox(height: 24.0),
              const Text(
                'Scoreboards:',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              InkWell(
                onTap: () {
                  Navigator.restorablePushNamed(context, '/scoreboard');
                  // Hier kannst du zur Schnellster Trichter Seite navigieren.
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE65100), Color(0xFFFFAB40)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schnellster Trichter',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Highscore Informationen hier...',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              InkWell(
                onTap: () {
                  // Hier kannst du zur Durchschnittliche Trichter Geschwindigkeit Seite navigieren.
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF004D40), Color(0xFF00BFA5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Höchste Durchschnittliche Trichter Geschwindigkeit',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Highscore Informationen hier...',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              InkWell(
                onTap: () {
                  // Hier kannst du zur Maximalgeschwindigkeit Seite navigieren.
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF311B92), Color(0xFF651FFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Höchste Maximalgeschwindigkeit',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Highscore Informationen hier...',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      print("http is sending");
                      http.Response res = await http.post(
                          Uri.parse('http://192.168.4.1/starttrichtermock'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          });
                      print("response status: ${res.statusCode}");
                      print(res.body);
                      Provider.of<TrichterManager>(context, listen: false)
                          .getTrichterList();
                    } catch (err) {}
                  },
                  child: const Text("Start Simulation Live Trichter")),
            ],
          ),
        ));
  }
}
