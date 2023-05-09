import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  NetworkNotifier? _notifier;

  Network._();

  factory Network() => _i;

  void init(BuildContext context) {
    _notifier = Provider.of<NetworkNotifier>(context, listen: false);
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _notifier?._disconnect();
      } else {
        _notifier?._connect();
      }
    });
  }

  void check() {
    Connectivity().checkConnectivity().then((ConnectivityResult result) {
      // if (_notifier?.isConnected == true) {
      //   _notifier?._disconnect();
      // } else {
      //   _notifier?._connect();
      // }
      if (result == ConnectivityResult.none) {
        _notifier?._disconnect();
      } else {
        _notifier?._connect();
      }
    });
  }
}
