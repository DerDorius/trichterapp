import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:trichterapp/src/dart/trichter_manager.dart';

class PlayerList extends StatefulWidget {
  const PlayerList({super.key, required this.onPlayerSelected});
  final void Function(String) onPlayerSelected;

  @override
  State<PlayerList> createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrichterManager>(
      builder: (context, trichterManager, child) {
        return ListView.builder(
          itemCount: trichterManager.trichterNamesAndAnzahl.length,
          shrinkWrap:
              true, // Wichtig: Diese Zeile ermöglicht das Scrollen innerhalb des Dialogs.
          itemBuilder: (context, index) {
            final names = trichterManager.trichterNamesAndAnzahl.keys.toList();
            return InkWell(
              onTap: () {
                widget.onPlayerSelected(names[index]);
              },
              child: ListTile(
                title: Text(
                    "${names[index]} (${trichterManager.trichterNamesAndAnzahl[names[index]]})"),
              ),
            );
          },
        );
      },
    );
  }
}
