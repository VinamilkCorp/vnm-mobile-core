import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkNotifier extends ChangeNotifier {
  bool _connected = true;

  bool get isConnected => _connected;

  void _connect() {
    if (_connected) return;
    _connected = true;
    notifyListeners();
  }

  void _disconnect() {
    if (!_connected) return;
    _connected = false;
    notifyListeners();
  }
}

class Network {
  static final Network _i = Network._();
  final NetworkNotifier _notifier = NetworkNotifier();
  bool _listened = false;

  Network._();

  factory Network() => _i;

  NetworkNotifier get notifier => _notifier;

  void _listen() {
    if (_listened) return;
    _listened = true;
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _notifier._disconnect();
      } else {
        _notifier._connect();
      }
    });
  }

  void check() {
    _listen();
    Connectivity().checkConnectivity().then((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _notifier._disconnect();
      } else {
        _notifier._connect();
      }
    });
  }
}
