import 'package:flutter/cupertino.dart';

import '../../material/exception/exception.dart';

class LoadingNotifier extends ChangeNotifier {
  bool _loading = false;

  bool get isLoading => _loading;

  void _show() {
    if (_loading) return;
    _loading = true;
    notifyListeners();
  }

  void _hide() {
    if (!_loading) return;
    _loading = false;
    notifyListeners();
  }
}

class Loader {
  static Loader _i = Loader._();
  LoadingNotifier _notifier = LoadingNotifier();

  Loader._();

  factory Loader() => _i;

  LoadingNotifier get notifier => _notifier;

  void show() {
    _notifier._show();
  }

  void hide() {
    _notifier._hide();
  }

  Future wrap({required Future Function() func}) async {
    try {
      show();
      var result = await func();
      return result;
    } catch (exception, stackTrace) {
      hide();
      VNMException().capture(exception, stackTrace);
    } finally {
      hide();
    }
  }
}
