import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerList extends StatefulWidget {
  const PlayerList({super.key, required this.onPlayerSelected});
  final void Function(String) onPlayerSelected;

  @override
  State<PlayerList> createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  List<String> names = [];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => {
          setState(() {
            names = value.getStringList("names") ?? [];
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: names.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(names[index]),
          onTap: () {
            widget.onPlayerSelected(names[index]);
          },
        );
      },
    );
  }
}
