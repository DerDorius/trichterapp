import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

const String _ssid = "Trichter";
const String _password = "12345678";

Future<bool> connectToTrichter() async {
  bool isWifiEnabled = await WiFiForIoTPlugin.isEnabled();
  if (!isWifiEnabled) {
    debugPrint("Enabling WiFi");
    await WiFiForIoTPlugin.setEnabled(true);
  } else {
    debugPrint("WiFi is already enabled");
    // check if connected To ssid
    String? currentSsid = await WiFiForIoTPlugin.getSSID();
    if (currentSsid == _ssid) {
      debugPrint("Already connected to Trichter");
      return true;
    } else {
      debugPrint("Checking for SSID nearby");

      final can = await WiFiScan.instance.canStartScan(askPermissions: true);
      if (can == CanStartScan.yes) {
        // start full scan async-ly
        final isScanning = await WiFiScan.instance.startScan();
        if (isScanning) {
          // get scan result
          final can = await WiFiScan.instance
              .canGetScannedResults(askPermissions: true);
          if (can == CanGetScannedResults.yes) {
            final results = await WiFiScan.instance.getScannedResults();
            debugPrint("Scan results: $results");
          }
        }
      }
    }
  }

  return true;
}
