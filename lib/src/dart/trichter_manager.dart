import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trichterapp/src/dart/trichter_model.dart';
import 'package:http/http.dart' as http;

class TrichterManager with ChangeNotifier {
  List<TrichterModel> trichterList = [];
  Map<String, int> trichterNamesAndAnzahl = {};

  void editTrichter(
      String uuid, String neuerName, bool gekotzt, bool erfolgreich) async {
    try {
      Uri uri = Uri.parse(
          'http://192.168.4.1/editTrichter?uuid=$uuid&name=$neuerName&erfolgreich=$erfolgreich&gekotzt=$gekotzt');

      http.Response res = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        /*  body: jsonEncode(<String, dynamic>{
          "uuid": uuid,
          "name": neuerName,
          "erfolgreich": erfolgreich,
          "gekotzt": gekotzt
        }), */
      );

      getTrichterList();
    } catch (err) {
      debugPrint("editTrichterError");
      debugPrint(err.toString());
    }
  }

  void getDetailsForTrichter(String uuid) async {
    // Hole die Daten vom Server
    Map<int, double> trichterData = {};

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? trichterDetails = prefs.getString(uuid);

    try {
      if (trichterDetails == null) {
        http.Response res = await http.get(
            Uri.parse('http://192.168.4.1/getTrichterDetails?uuid=$uuid'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            });
        if (res.statusCode == 200) {
          trichterDetails = res.body;
          prefs.setString(uuid, trichterDetails);
        }
      }
      if (trichterDetails != null) {
        // parse into List
        trichterData.clear();

        List<dynamic> data = jsonDecode(trichterDetails);
        for (var value in data) {
          if (value["t"] != null) {
            trichterData
                .addEntries([MapEntry<int, double>(value["t"], value["d"])]);
          }
        }

        // put list into trichterModel
        for (var element in trichterList) {
          if (element.uuid == uuid) {
            element.trichterData = trichterData;
            element.berechneAlles();
            break;
          }
        }
        notifyListeners();
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<void> getTrichterList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Otherwise, store the new ThemeMode in memory
    String trichterString = "{}";

    try {
      try {
        http.Response res = await http.get(
            Uri.parse('http://192.168.4.1/getAllTrichter'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            }).timeout(const Duration(seconds: 2));
        if (res.statusCode == 200) {
          trichterString = res.body;
          prefs.setString("trichterlist", trichterString);
        }
      } catch (err) {
        if (prefs.getString("trichterlist") != null) {
          trichterString = prefs.getString("trichterlist")!;
        }
      }

      // parse into List
      Map<String, dynamic> trichterMap = jsonDecode(trichterString);
      trichterList = [];
      trichterMap.forEach((uuid, value) {
        try {
          trichterList.add(TrichterModel(
              uuid: uuid,
              name: value["name"],
              mengeInLiter: value["l"],
              maxGeschwindigkeit: value["max"],
              avgDurchfluss: value["avg"],
              dauerInMs: value["ms"],
              erfolgreich: value["erf"],
              hatGekotzt: value["kotz"]));
        } catch (err) {
          debugPrint(value.toString());
          debugPrint("trichter couldnt be parsed");
          debugPrint(err.toString());
        }
      });
      // fill trichternames list and sort it
      trichterNamesAndAnzahl = {};

      for (var element in trichterList) {
        if (trichterNamesAndAnzahl.containsKey(element.name)) {
          trichterNamesAndAnzahl[element.name] =
              trichterNamesAndAnzahl[element.name]! + 1;
        } else {
          trichterNamesAndAnzahl[element.name] = 1;
        }
      }

      notifyListeners();
    } catch (err) {
      debugPrint("getTrichterListError");
      debugPrint(err.toString());
    }
    return;
  }
}
