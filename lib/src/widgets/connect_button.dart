// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trichterapp/src/dart/websocketmanager.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

WebSocketManager webSocketManager = WebSocketManager();

class TrichterConnectButton extends StatefulWidget {
  const TrichterConnectButton({super.key});

  @override
  State<TrichterConnectButton> createState() => _TrichterConnectButtonState();
}

class _TrichterConnectButtonState extends State<TrichterConnectButton> {
  bool isDiscovering = false;

  bool isTrichterFound = false;
  bool isWifiEnabled = false;
  bool _isConnectedToTrichter = false;
  bool isConnectedToWebSocket = false;
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  List<WiFiAccessPoint> accessPoints = [];

  final String _ssid = "Trichter";
  final String _password = "12345678";
  Future<bool> connect() async {
    try {
      setState(() {
        isDiscovering = true;
      });
      bool isWifiEnabled = await WiFiForIoTPlugin.isEnabled();
      if (!isWifiEnabled) {
        debugPrint("Enabling WiFi");
        await WiFiForIoTPlugin.setEnabled(true);
      }
      isWifiEnabled = await WiFiForIoTPlugin.isEnabled();
      if (isWifiEnabled) {
        debugPrint("WiFi is already enabled");
        // check if connected To ssid
        String? currentSsid = await WiFiForIoTPlugin.getSSID();
        if (currentSsid == _ssid) {
          debugPrint("Already connected to Trichter");
          if (!webSocketManager.isConnected) {
            isConnectedToWebSocket =
                await webSocketManager.initializeWebSocket();
          }

          if (mounted) {
            setState(() {
              isDiscovering = false;
              isConnectedToWebSocket = webSocketManager.isConnected;
              _isConnectedToTrichter = true;
              isWifiEnabled = true;
              isTrichterFound = true;
            });
          }
          return true;
        } else {
          debugPrint("Checking for SSID nearby");

          final can =
              await WiFiScan.instance.canStartScan(askPermissions: true);
          if (can == CanStartScan.yes) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Suche nach Trichter'),
              ),
            );
            // start full scan async-ly
            final isScanning = await WiFiScan.instance.startScan();
            if (isScanning) {
              // get scan result
              final can = await WiFiScan.instance
                  .canGetScannedResults(askPermissions: true);
              if (can == CanGetScannedResults.yes) {
                subscription = WiFiScan.instance.onScannedResultsAvailable
                    .listen((results) {
                  // update accessPoints
                  debugPrint("Scan results: $results");
                  // check if ssid is in results
                  for (var accessPoint in results) {
                    if (accessPoint.ssid == _ssid) {
                      debugPrint("Found Trichter");
                      isTrichterFound = true;
                      // connect to ssid
                      WiFiForIoTPlugin.connect(_ssid,
                              password: _password,
                              security: NetworkSecurity.WPA)
                          .then((value) async {
                        debugPrint("Connected to Trichter");
                        WiFiForIoTPlugin.forceWifiUsage(true);

                        isConnectedToWebSocket =
                            await webSocketManager.initializeWebSocket();

                        if (mounted) {
                          setState(() {
                            isDiscovering = false;
                            isConnectedToWebSocket = isConnectedToWebSocket;
                            _isConnectedToTrichter = true;
                            isWifiEnabled = true;
                            isTrichterFound = true;
                          });
                        }
                        // only when mounted
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Verbunden mit Trichter'),
                              showCloseIcon: true,
                            ),
                          );
                        }
                      });
                    }
                  }
                  if (mounted) {
                    setState(() => accessPoints = results);
                  }
                });
              }
            }
          }
        }
      } else {
        debugPrint("WiFi could not be enabled");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'WLAN musste erst aktiviert werden. Bitte nochmal versuchen'),
          ),
        );
        if (mounted) {
          setState(() {
            isDiscovering = false;
            _isConnectedToTrichter = false;
            isWifiEnabled = false;
            isTrichterFound = false;
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    debugPrint("HHALLALLALAOooOO");
    try {
      isConnectedToWebSocket = await webSocketManager.initializeWebSocket();

      if (mounted) {
        setState(() {
          isConnectedToWebSocket = isConnectedToWebSocket;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return isConnectedToWebSocket;
  }

  @override
  void initState() {
    super.initState();
    connect();
  }

  // make sure to cancel subscription after you are done
  @override
  dispose() {
    super.dispose();
    subscription?.cancel();
  }

  Icon getIcon() {
    if (_isConnectedToTrichter && isConnectedToWebSocket) {
      return const Icon(Icons.wifi);
    } else if (_isConnectedToTrichter && !isConnectedToWebSocket) {
      return const Icon(Icons.signal_wifi_statusbar_connected_no_internet_4);
    } else if (isTrichterFound) {
      return const Icon(Icons.network_check);
    } else if (_isConnectedToTrichter) {
      return const Icon(Icons.wifi);
    } else if (isWifiEnabled) {
      return const Icon(Icons.wifi_find);
    } else if (!isWifiEnabled) {
      return const Icon(Icons.wifi_off);
    } else {
      return const Icon(Icons.signal_wifi_statusbar_null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isDiscovering
        ? FittedBox(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
        : IconButton(
            icon: getIcon(),
            onPressed: connect,
          );
  }
}
