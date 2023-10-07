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
