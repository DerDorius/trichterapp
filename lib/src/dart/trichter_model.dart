import 'package:flutter/material.dart';

class TrichterModel {
  String name;
  String uuid;

  // Int ist in ms und double in l/s
  Map<int, double> trichterData = {};

  double mengeInLiter;
  double maxGeschwindigkeit;
  double avgDurchflussInMl;
  double mengeImErstenSchluckInL;
  int dauerInMs;
  int anzahlSchluecke;

  bool erfolgreich;
  bool hatGekotzt;

  // konstruktor mit allem:
  TrichterModel({
    this.name = "Nicht Zugeordnet",
    this.uuid = "",
    this.mengeInLiter = 0,
    this.maxGeschwindigkeit = 0,
    this.avgDurchflussInMl = 0,
    this.dauerInMs = 1,
    this.mengeImErstenSchluckInL = 0,
    this.anzahlSchluecke = 0,
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
    debugPrint("berechneAvgDurchfluss");
    debugPrint(mengeInLiter.toString());
    debugPrint(dauerInMs.toString());
    avgDurchflussInMl = mengeInLiter / (dauerInMs / 1000) * 1000;
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

  void berechneAnzahlSchluecke() {
    if (trichterData.length < 5) {
      anzahlSchluecke = 0;
    }

    anzahlSchluecke = 0;
    List<int> zeitpunkte = trichterData.keys.toList();

    for (int i = 2; i < zeitpunkte.length - 2; i++) {
      double vorheriger1 = trichterData[zeitpunkte[i - 1]]!;
      double vorheriger2 = trichterData[zeitpunkte[i - 2]]!;
      double nachfolgender1 = trichterData[zeitpunkte[i + 1]]!;
      double nachfolgender2 = trichterData[zeitpunkte[i + 2]]!;
      double aktuellerWert = trichterData[zeitpunkte[i]]!;

      if (aktuellerWert >= vorheriger1 &&
          aktuellerWert > vorheriger2 &&
          aktuellerWert >= nachfolgender1 &&
          aktuellerWert > nachfolgender2) {
        anzahlSchluecke++;
      }
    }
  }

  void berechneMengeImErstenSchluck() {
    mengeImErstenSchluckInL = 0;

    List<int> zeitpunkte = trichterData.keys.toList();

    for (int i = 2; i < zeitpunkte.length - 2; i++) {
      double vorheriger1 = trichterData[zeitpunkte[i - 1]]!;
      double vorheriger2 = trichterData[zeitpunkte[i - 2]]!;
      double nachfolgender1 = trichterData[zeitpunkte[i + 1]]!;
      double nachfolgender2 = trichterData[zeitpunkte[i + 2]]!;
      double aktuellerWert = trichterData[zeitpunkte[i]]!;

      if (aktuellerWert <= vorheriger1 &&
          aktuellerWert < vorheriger2 &&
          aktuellerWert <= nachfolgender1 &&
          aktuellerWert < nachfolgender2) {
        // Wir haben den Anfang des ersten Tiefpunkts gefunden
        // Berechne die Menge im ersten Tiefpunkt bis zu diesem Zeitpunkt
        mengeImErstenSchluckInL = berechneMengeBisZeitpunkt(zeitpunkte[i]);

        debugPrint(
            "Zeitpunkt (Tiefpunkt): " + zeitpunkte[i].toString() + " ms");
        break;
      }
    }
  }

  double berechneMengeBisZeitpunkt(int zeitpunkt) {
    if (trichterData.isEmpty) {
      return 0.0;
    }

    double mengeInLiter = 0.0;
    int letzterZeitpunkt = -1;

    trichterData.forEach((aktuelleZeitpunkt, durchfluss) {
      if (aktuelleZeitpunkt <= zeitpunkt) {
        if (letzterZeitpunkt != -1) {
          double vergangeneZeitInSekunden =
              (aktuelleZeitpunkt - letzterZeitpunkt) / 1000.0;
          double mengeInDieserZeitspanne =
              durchfluss * vergangeneZeitInSekunden / 60.0;
          mengeInLiter += mengeInDieserZeitspanne;
        }
        letzterZeitpunkt = aktuelleZeitpunkt;
      }
    });

    return mengeInLiter;
  }

  void berechneAlles() {
    sortiereTrichterData();
    berechneDauerInMs();
    berechneLiter();
    berechneAvgDurchfluss();
    berechneMaxGeschwindigkeit();
    berechneAnzahlSchluecke();
    berechneMengeImErstenSchluck();
  }
}
