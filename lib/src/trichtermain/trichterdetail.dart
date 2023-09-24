import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trichterapp/src/dart/trichter_model.dart';
import 'package:trichterapp/src/dart/websocketmanager.dart';
import 'package:trichterapp/src/widgets/connect_button.dart';
import 'package:http/http.dart' as http;
import 'package:trichterapp/src/widgets/stat.dart';
import 'package:trichterapp/src/widgets/trichter_chart.dart';

/// Displays detailed information about a SampleItem.
class TrichterDetail extends StatefulWidget {
  TrichterDetail(
      {super.key,
      required this.liveTrichterData,
      required this.isLive,
      this.trichterDetail});
  Map<int, double> liveTrichterData;
  bool isLive;
  TrichterDetail? trichterDetail;

  static const routeName = '/sample_item';

  @override
  State<TrichterDetail> createState() => _TrichterDetailState();
}

class _TrichterDetailState extends State<TrichterDetail> {
  String receivedMessage = "";
  StreamSubscription? subscription;
  WebSocketManager webSocketManager = WebSocketManager();
  String currentName = "";
  List<String> names = [];
  TrichterModel trichterModel = TrichterModel();

  @override
  void initState() {
    super.initState();

    // Subscribe to the message stream
    subscription = webSocketManager.messageStream.listen((message) {
      setState(() {
        receivedMessage += message;
      });
    });

    SharedPreferences.getInstance().then((value) => {
          if (mounted)
            {
              setState(() {
                names = value.getStringList("names") ?? [];
              })
            }
        });
  }

  @override
  void didUpdateWidget(TrichterDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Diese Methode wird aufgerufen, wenn das Widget aktualisiert wird.
    // Hier können Sie auf Zustandsänderungen reagieren.
    if (widget.isLive) {
      trichterModel.trichterData = widget.liveTrichterData;
      trichterModel.berechneAlles();
    }
    print('Widget wurde aktualisiert');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trichter Details'),
        actions: const [TrichterConnectButton()],
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Name',
                        ),
                        onSubmitted: (String value) async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          names.add(value);
                          prefs.setStringList("names", names);
                          setState(() {
                            currentName = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_search), // Benutzer-Icon
                      onPressed: () {
                        // Die Aktion, die bei einem Klick auf den IconButton ausgeführt werden soll
                      },
                    ),
                  ],
                )),
            TrichterChart(trichterData: widget.liveTrichterData),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stat(
                      size: 100,
                      count: trichterModel.dauerInMs / 10,
                      title: "Sekunden"),
                  const Divider(
                    height: 20,
                    thickness: 5,
                    indent: 20,
                    endIndent: 0,
                    color: Colors.red,
                  ),
                  Stat(
                      size: 190,
                      count: trichterModel.maxGeschwindigkeit,
                      title: "ml/s max"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stat(
                      size: 100,
                      count: trichterModel.mengeInLiter,
                      title: "Liter"),
                  const Divider(
                    height: 20,
                    thickness: 5,
                    indent: 20,
                    endIndent: 0,
                    color: Colors.red,
                  ),
                  Stat(
                      size: 190,
                      count: trichterModel.avgDurchfluss,
                      title: "ml/s avg"),
                ],
              ),
            ),
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
                  } catch (err) {}
                },
                child: const Text("Simuliere Live Trichter auf Arduino")),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Don't forget to unsubscribe from the message stream when the widget is disposed
    webSocketManager.messageStream.drain();
    subscription?.cancel();
    super.dispose();
  }
}
