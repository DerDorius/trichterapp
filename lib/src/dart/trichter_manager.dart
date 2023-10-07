import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trichterapp/src/dart/trichter_model.dart';
import 'package:http/http.dart' as http;

class TrichterManager with ChangeNotifier {
  List<TrichterModel> trichterList = [];

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
          trichterList.add(TrichterModel(
              uuid: uuid,
              name: value["name"],
              mengeInLiter: value["l"],
              maxGeschwindigkeit: value["max"],
              avgDurchfluss: value["avg"],
              dauerInMs: value["ms"],
              erfolgreich: value["erf"],
              hatGekotzt: value["kotz"]));
        });
      }
      notifyListeners();
    } catch (err) {
      debugPrint(err.toString());
    }
  }
}
