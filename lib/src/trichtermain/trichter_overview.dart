import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trichterapp/src/dart/trichter_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:trichterapp/src/widgets/connect_button.dart';
import 'package:trichterapp/src/widgets/trichter_summary_card.dart'; // Import für die Formatierung der Zahlen

class TrichterOverview extends StatefulWidget {
  static const routeName = "/trichteroverview";

  const TrichterOverview({Key? key}) : super(key: key);

  @override
  State<TrichterOverview> createState() => _TrichterOverviewState();
}

class _TrichterOverviewState extends State<TrichterOverview> {
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
            child: Consumer<TrichterManager>(
                builder: (context, trichterManager, child) {
              // mache eine Kopie der Liste
              final trichterList = [...trichterManager.trichterList];
              // sortier nach Menge
              trichterList
                  .sort((a, b) => b.mengeInLiter.compareTo(a.mengeInLiter));

              return ListView.builder(
                itemCount: trichterList.length,
                itemBuilder: (context, index) {
                  return TrichterSummaryCard(
                    titleText: 'Platz ${index + 1} ',
                    uuid: trichterList[index].uuid,
                    trichterName: trichterList[index].name,
                    dauerText: "${trichterList[index].dauerInMs / 1000}s",
                    maxDurchflussText:
                        "${format.format(trichterList[index].maxGeschwindigkeit)} L/s",
                    avgDurchflussText:
                        "${format.format(trichterList[index].avgDurchflussInMl)} ml/s",
                    mengeText:
                        "${format.format(trichterList[index].mengeInLiter)} Liter",
                  );
                },
              );
            })),
      ),
    );
  }
}
