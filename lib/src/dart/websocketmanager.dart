import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();

  Map<int, double> liveTrichterData = {};

  factory WebSocketManager() {
    return _instance;
  }

  WebSocketManager._internal();

  bool isConnected = false;
  late IOWebSocketChannel _channel;

  final _messageController = StreamController<String>.broadcast();

  Stream<String> get messageStream => _messageController.stream;

  void initializeWebSocket() async {
    String? currentSsid = await WiFiForIoTPlugin.getSSID();
    if (currentSsid == "Trichter") {
      debugPrint("Already connected to Trichter");
      debugPrint("INITIALIEIRERRe WS");

      _channel = IOWebSocketChannel.connect('ws://192.168.4.1:80/ws');
      try {
        await _channel.ready;
        isConnected = true;
        _channel.stream.listen((message) {
          onMessage(message);
        }, onDone: () {
          // Handle disconnection and try to reconnect
          isConnected = false;
          _reconnect();
        }, onError: (error) {
          // Handle error and try to reconnect
          isConnected = false;
          _reconnect();
        });
      } catch (e) {
        // handle exception here
        debugPrint("WebsocketChannel was unable to establishconnection");
      }
    }
  }

  void onMessage(String message) {
    _messageController.add(message); // Send message to the stream

    // Parse json message if its json
  }

  void _reconnect() async {
    String? currentSsid = await WiFiForIoTPlugin.getSSID();
    if (currentSsid == "Trichter") {
      Future.delayed(const Duration(seconds: 5), () {
        if (!isConnected) {
          initializeWebSocket();
        }
      });
    }
  }

  void closeWebSocket() {
    if (isConnected) {
      _channel.sink.close();
      isConnected = false;
    }
  }

  void sendMessage(String message) {
    if (isConnected) {
      _channel.sink.add(message);
    }
  }
}
