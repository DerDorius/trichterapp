// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceList extends StatefulWidget {
  const DeviceList({
    super.key,
    this.items = const ["hi", "hi", "hi"],
  });
  final List<String> items;

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  bool isBluetoothAvailable = false;
  Map<DeviceIdentifier, ScanResult> devices = {};
  FlutterBlue flutterBlue = FlutterBlue.instance;
  @override
  void initState() {
    super.initState();

    setUpBluetooth();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setUpBluetooth() async {
    // check adapter availability
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await flutterBlue.isAvailable == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    if (await flutterBlue.isOn) {
      // bluetooth is on!
      setState(() {
        isBluetoothAvailable = true;
      });
    }

    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.id}: "${r.device.name}" found! rssi: ${r.rssi}');
        setState(() {
          devices[r.device.id] = r;
        });
        //devices.addAll({r.device.remoteId: r});
      }
    });
  }

  void scanFor5Seconds() async {
    await flutterBlue.startScan(timeout: const Duration(seconds: 5));
    Future.delayed(const Duration(seconds: 5), () async {
      await flutterBlue.stopScan();
      print("scan stopped");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        isBluetoothAvailable
            ? ElevatedButton.icon(
                onPressed: () {
                  scanFor5Seconds();
                  print("devices");
                  print(devices.length);
                },
                icon: const Icon(Icons.refresh),
                label: Text("Bluetooth Scannen${devices.length}"))
            : ElevatedButton.icon(
                onPressed: () {
                  setUpBluetooth();
                },
                icon: const Icon(Icons.bluetooth),
                label: const Text("Bluetooth aktivieren")),
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: devices.length,
            itemBuilder: (BuildContext context, int index) {
              final device = devices.values.elementAt(index);

              return ListTile(
                  title: Text(device.device.name == ""
                      ? "unknown:${device.device.id}"
                      : device.device.name),
                  // leading bluetooth icon
                  leading: const Icon(Icons.bluetooth),
                  onTap: () {});
            }),
      ],
    );
  }
}
