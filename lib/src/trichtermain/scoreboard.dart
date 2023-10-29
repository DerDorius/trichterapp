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
  static final format = NumberFormat("##0.0#", 'de_DE');

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
        child: RefreshIndicator(
            onRefresh: () =>
                Provider.of<TrichterManager>(context, listen: false)
                    .getTrichterList(),
            child: ListView(
              children: [
                Consumer<TrichterManager>(
                  builder: (context, trichterManager, child) {
                    final trichterList = trichterManager.trichterList;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 16.0, // Spacing between columns
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text('Name'),
                            numeric: false, // The column is not numeric
                          ),
                          DataColumn(
                            label: Text('L'),
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
                            label: Text('Max'),
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
                              DataCell(
                                  Hero(
                                    tag: "${trichter.uuid}trichterName",
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: trichter.name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () => Navigator.pushNamed(
                                      context, "/trichter_details",
                                      arguments: trichter.uuid)),
                              DataCell(Text(
                                format.format(trichter.mengeInLiter),
                              )),
                              DataCell(Text(
                                format.format(trichter.avgDurchflussInMl),
                              )),
                              DataCell(Text(
                                format.format(trichter.dauerInMs / 1000),
                              )),
                              DataCell(Text(
                                format.format(trichter.maxGeschwindigkeit),
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
            )),
      ),
    );
  }
}
