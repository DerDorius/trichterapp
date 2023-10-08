import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trichterapp/src/dart/trichter_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:trichterapp/src/widgets/connect_button.dart'; // Import für die Formatierung der Zahlen

class Scoreboard extends StatefulWidget {
  static const routeName = "/scoreboard";

  const Scoreboard({Key? key}) : super(key: key);

  @override
  State<Scoreboard> createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> {
  @override
  void initState() {
    super.initState();
    Provider.of<TrichterManager>(context, listen: false).getTrichterList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Trichtern'),
        actions: const [
          TrichterConnectButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Consumer<TrichterManager>(
              builder: (context, trichterManager, child) {
                final trichterList = trichterManager.trichterList;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16.0, // Spacing zwischen den Spalten
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text('Name'),
                        // Hier setzen Sie die Fixbreite für die Spalte "Name"
                        numeric: false, // Die Spalte ist nicht numerisch
                      ),
                      DataColumn(
                        label: Text('L'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Max'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Avg'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Sek'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('✅'),
                        numeric: false,
                      ),
                      DataColumn(
                        label: Text('🤮'),
                        numeric: false,
                      ),
                    ],
                    rows: trichterList.map((trichter) {
                      debugPrint("Trichter: ${trichter.uuid}");
                      return DataRow(
                        onLongPress: () => Navigator.pushNamed(
                            context, "/trichter_details",
                            arguments: trichter.uuid),
                        cells: <DataCell>[
                          DataCell(Text(trichter.name),
                              onTap: () => Navigator.pushNamed(
                                  context, "/trichter_details",
                                  arguments: trichter.uuid)),
                          DataCell(Text(
                            NumberFormat.decimalPattern("de_DE")
                                .format(trichter.mengeInLiter),
                          )),
                          DataCell(Text(
                            NumberFormat.decimalPattern("de_DE")
                                .format(trichter.maxGeschwindigkeit),
                          )),
                          DataCell(Text(
                            NumberFormat.decimalPattern("de_DE")
                                .format(trichter.avgDurchfluss),
                          )),
                          DataCell(Text(
                            NumberFormat.decimalPattern("de_DE")
                                .format(trichter.dauerInMs / 1000),
                          )),
                          DataCell(Text(trichter.erfolgreich ? "✅" : "❌")),
                          DataCell(Text(trichter.hatGekotzt ? "✅" : "❌")),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
