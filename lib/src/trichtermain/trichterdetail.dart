import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trichterapp/src/dart/trichter_manager.dart';
import 'package:trichterapp/src/dart/trichter_model.dart';
import 'package:trichterapp/src/widgets/connect_button.dart';
import 'package:trichterapp/src/widgets/player_list.dart';
import 'package:trichterapp/src/widgets/stat.dart';
import 'package:trichterapp/src/widgets/trichter_chart.dart';

/// Displays detailed information about a SampleItem.
class TrichterDetail extends StatefulWidget {
  Map<int, double> liveTrichterData;
  TrichterDetail? trichterDetail;
  String uuid;
  bool isLive;
  TrichterDetail(
      {super.key,
      required this.liveTrichterData,
      required this.isLive,
      required this.uuid,
      this.trichterDetail});

  static const routeName = '/trichter_details';

  @override
  State<TrichterDetail> createState() => _TrichterDetailState();
}

class _TrichterDetailState extends State<TrichterDetail> {
  String receivedMessage = "";
  String currentName = "";
  List<String> names = [];
  TrichterModel trichterModel = TrichterModel();
  bool nameEditMode = false;
  late FocusNode textFieldFocusNode;
  final nameTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (!widget.isLive) {
      // hol aus der trichterliste den trichter mit der uuid
      // und setze ihn als trichterDetail

      Provider.of<TrichterManager>(context, listen: false)
          .trichterList
          .forEach((element) {
        if (element.uuid == widget.uuid) {
          trichterModel = element;
          debugPrint("Trichter gefunden ${widget.uuid}");
          Provider.of<TrichterManager>(context, listen: false)
              .getDetailsForTrichter(widget.uuid);
          currentName = trichterModel.name;
          nameTextEditingController.text = trichterModel.name;
        }
      });
    } else {
      trichterModel.trichterData = widget.liveTrichterData;
      trichterModel.berechneAlles();
      currentName = "Live Trichter";
    }

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
    } else {}
    print('Widget wurde aktualisiert');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.filter_alt_outlined),
            const SizedBox(width: 10),
            Text(widget.isLive ? "Live Trichter" : 'Trichter Details'),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Trichter Löschen?'),
                      content: const Text('Wirklich löschen?????'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Neeee'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<TrichterManager>(context, listen: false)
                                .deleteTrichter(widget.uuid);
                            Navigator.pop(context, 'OK');
                            Navigator.pop(context);
                          },
                          child: const Text('Doooch'),
                        ),
                      ],
                    ),
                  ),
              icon: const Icon(Icons.delete)),
          const TrichterConnectButton()
        ],
      ),
      body: Center(
        child: Consumer<TrichterManager>(
            builder: (context, trichterManager, child) {
          return Column(
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: nameEditMode
                            ? TextField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Name',
                                ),
                                controller: nameTextEditingController,
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                                child: Hero(
                                  tag: "${trichterModel.uuid}trichterName",
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: currentName,
                                          style: const TextStyle(
                                            fontSize: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      IconButton(
                        icon: nameEditMode
                            ? const Icon(Icons.check)
                            : const Icon(Icons.edit), // Benutzer-Icon
                        onPressed: () {
                          if (nameEditMode) {
                            trichterManager.editTrichter(
                                widget.uuid,
                                nameTextEditingController.text,
                                trichterModel.hatGekotzt,
                                trichterModel.erfolgreich);

                            setState(() {
                              currentName = nameTextEditingController.text;
                            });
                          }

                          setState(() {
                            nameEditMode = !nameEditMode;
                          });

                          // Die Aktion, die bei einem Klick auf den IconButton ausgeführt werden soll
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_search), // Benutzer-Icon
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Wähle dich!'),
                            content: Container(
                                height: 400.0, // Change as per your requirement
                                width:
                                    300.0, // Change as per your                                 // Verwende SingleChildScrollView anstelle von ListView.
                                child: PlayerList(onPlayerSelected: (p1) {
                                  setState(() {
                                    currentName = p1;
                                    nameTextEditingController.text = p1;
                                  });
                                  Provider.of<TrichterManager>(context,
                                          listen: false)
                                      .editTrichter(
                                          widget.uuid,
                                          p1,
                                          trichterModel.hatGekotzt,
                                          trichterModel.erfolgreich);
                                  Navigator.pop(context, p1);
                                })),
                          ),
                        ),
                      ),
                    ],
                  )),
              TrichterChart(trichterData: trichterModel.trichterData),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stat(
                        size: 100,
                        isLeft: true,
                        count: trichterModel.dauerInMs / 1000,
                        title: "Sekunden"),
                    const Divider(
                      height: 20,
                      thickness: 2,
                      indent: 10,
                      endIndent: 0,
                      color: Colors.red,
                    ),
                    Stat(
                        size: 190,
                        isLeft: false,
                        count: trichterModel.maxGeschwindigkeit,
                        title: "L/s max"),
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
                        isLeft: true,
                        count: trichterModel.mengeInLiter,
                        title: "Liter"),
                    const Divider(
                      height: 20,
                      thickness: 5,
                      indent: 10,
                      endIndent: 0,
                      color: Colors.red,
                    ),
                    Stat(
                        size: 190,
                        isLeft: false,
                        count: trichterModel.avgDurchflussInMl,
                        title: "ml/s ∅"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stat(
                        size: 190,
                        isLeft: true,
                        count: trichterModel.anzahlSchluecke.toDouble(),
                        title: "Schlücke"),
                    const Divider(
                      height: 20,
                      thickness: 5,
                      indent: 10,
                      endIndent: 0,
                      color: Colors.red,
                    ),
                    Stat(
                        size: 190,
                        isLeft: false,
                        count: trichterModel.mengeImErstenSchluckInL,
                        title: "L im 1. Schluck"),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    // Don't forget to unsubscribe from the message stream when the widget is disposed
    super.dispose();
  }
}
