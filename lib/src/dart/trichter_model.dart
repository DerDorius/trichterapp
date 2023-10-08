import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TrichterModel {
  String name;
  String uuid;

  // Int ist in ms und double in l/s
  Map<int, double> trichterData = {};

  double mengeInLiter;
  double maxGeschwindigkeit;
  double avgDurchfluss;
  int dauerInMs;

  bool erfolgreich;
  bool hatGekotzt;

  // konstruktor mit allem:
  TrichterModel({
    this.name = "Nicht Zugeordnet",
    this.uuid = "",
    this.mengeInLiter = 0,
    this.maxGeschwindigkeit = 0,
    this.avgDurchfluss = 0,
    this.dauerInMs = 1,
    this.erfolgreich = true,
    this.hatGekotzt = false,
  });

  void sortiereTrichterData() {
    trichterData = Map.fromEntries(trichterData.entries.toList()
      ..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }

  void berechneDauerInMs() {
    if (trichterData.isEmpty) {
      dauerInMs = 0;
      return;
    }
    dauerInMs = trichterData.keys.last;
  }

  void berechneAvgDurchfluss() {
    if (trichterData.isEmpty) {
      avgDurchfluss = 0;
      return;
    }
    double summeDurchfluss = trichterData.values.reduce((a, b) => a + b);
    avgDurchfluss = summeDurchfluss / trichterData.length;
  }

  // berechne Liter aus der Zeit und der Geschwindigkeit in l/s
  void berechneLiter() {
    if (trichterData.isEmpty) {
      this.mengeInLiter = 0;
      return;
    }

    // Initialisiere die Menge in Litern mit 0.
    double mengeInLiter = 0;

    // Iteriere durch die Map.
    int letzteZeitpunkt = -1;
    trichterData.forEach((zeitpunkt, durchfluss) {
      if (letzteZeitpunkt != -1) {
        // Berechne die vergangene Zeit in Sekunden (von ms in s umrechnen).
        double vergangeneZeitInSekunden =
            (zeitpunkt - letzteZeitpunkt) / 1000.0;

        // Berechne die Menge in Litern, die in dieser Zeitspanne geflossen ist.
        double mengeInDieserZeitspanne =
            durchfluss * vergangeneZeitInSekunden / 60.0; // von L/min zu L

        // Addiere die Menge zur Gesamtmenge hinzu.
        mengeInLiter += mengeInDieserZeitspanne;
      }
      letzteZeitpunkt = zeitpunkt;
    });

    // Setze die berechnete Menge in die entsprechende Variable.
    this.mengeInLiter = mengeInLiter;
  }

  void berechneMaxGeschwindigkeit() {
    if (trichterData.isEmpty) {
      maxGeschwindigkeit = 0;
      return;
    }
    maxGeschwindigkeit = trichterData.values.reduce((a, b) => a > b ? a : b);
  }

  void berechneAlles() {
    sortiereTrichterData();
    berechneDauerInMs();
    berechneLiter();
    berechneAvgDurchfluss();
    berechneMaxGeschwindigkeit();
  }
}
