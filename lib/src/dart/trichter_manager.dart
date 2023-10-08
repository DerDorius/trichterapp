import 'dart:convert';

import 'package:flutter/material.dart';
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
      debugPrint("editTrichter");
      debugPrint(res.body);
      debugPrint(res.statusCode.toString());
      getTrichterList();
    } catch (err) {
      debugPrint("editTrichterError");
      debugPrint(err.toString());
    }
  }

  void getTrichterList() async {
    try {
      http.Response res = await http.get(
          Uri.parse('http://192.168.4.1/getAllTrichter'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      debugPrint("getTrichterList");
      debugPrint(res.body);
      debugPrint(res.statusCode.toString());
      if (res.statusCode == 200) {
        debugPrint(res.body);
        // parse into List
        Map<String, dynamic> trichterMap = jsonDecode(res.body);
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
            debugPrint("trichter couldnt be parsed");
            debugPrint(err.toString());
          }
        });
      }
      // fill trichternames list and sort it
      trichterNamesAndAnzahl = {};
      List<TrichterModel> sortedList = trichterList;
      sortedList.sort((a, b) => a.name.compareTo(b.name));
      for (var element in sortedList) {
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
  }
}
