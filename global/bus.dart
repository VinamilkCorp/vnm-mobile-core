class BusRequest<T> {
  final String event;
  final T? data;

  BusRequest(this.event, [this.data]);
}

class VNMBus {
  static final VNMBus _i = VNMBus._();
  final Map<String, Function(dynamic data)> _events1 = {};
  final Map<String, Function(dynamic arg1, dynamic arg2)> _events2 = {};
  final Map<String, Function()> _events = {};
  final Map<String, dynamic> _values = {};

  VNMBus._();

  factory VNMBus() => _i;

  //trigger
  T? touch<T>(String event) {
    if (_values[event] != null) {
      var result = _values[event];
      return result is T ? result : null;
    }
    return null;
  }

  Future<T?> fire<T>(String event, [dynamic arg1, dynamic arg2]) async {
    if (_events[event] != null) {
      var result = await _events[event]!();
      return result is T ? result : null;
    } else if (_events1[event] != null) {
      var result = await _events1[event]!(arg1);
      return result is T ? result : null;
    } else if (_events2[event] != null) {
      var result = await _events2[event]!(arg1, arg2);
      return result is T ? result : null;
    }
    return null;
  }

  //register
  void register1(String event, Function(dynamic data) trigger) {
    _events1[event] = trigger;
  }

  void register2(String event, Function(dynamic arg1, dynamic arg2) trigger) {
    _events2[event] = trigger;
  }

  void registerValue(String event, dynamic value) {
    _values[event] = value;
  }

  void register(String event, Function() trigger) {
    _events[event] = trigger;
  }
}
