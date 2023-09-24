class TrichterModel {
  String name = "Nicht Zugeordnet";
  String uuid = "";

  // Int ist in ms und double in l/s
  Map<int, double> trichterData = {};

  double mengeInLiter = 0;
  double maxGeschwindigkeit = 0;
  double avgDurchfluss = 0;
  int dauerInMs = 1;

  bool erfolgreich = true;
  bool hatGekotzt = false;

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
      mengeInLiter = 0;
      return;
    }
    double summeDurchfluss = trichterData.values.reduce((a, b) => a + b);
    mengeInLiter = (summeDurchfluss * dauerInMs) / 1000;
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
