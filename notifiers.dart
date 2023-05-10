import 'package:flutter/material.dart';

class IntNotifier extends ChangeNotifier {
  int? _value;

  int? get value => _value;

  set value(int? value) => _value = value;

  void setValue(int? value) {
    if (_value != value) {
      _value = value;
      notifyListeners();
    }
  }
}

class DoubleNotifier extends ChangeNotifier {
  double? _value;

  double? get value => _value;

  set value(double? value) => _value = value;

  void setValue(double? value) {
    if (_value != value) {
      _value = value;
      notifyListeners();
    }
  }
}

class BoolNotifier extends ChangeNotifier {
  bool? _value;

  bool get isTrue => _value == true;

  bool get isFalse => _value == false;

  bool? get value => _value;

  set value(bool? value) => _value = value;

  void setValue(bool? value) {
    if (_value != value) {
      _value = value;
      notifyListeners();
    }
  }
}

class ObjectNotifier<T> extends ChangeNotifier {
  T? _value;

  T? get value => _value;

  set value(T? value) => _value = value;

  void setValue(T? value) {
    if (_value != value) {
      _value = value;
      notifyListeners();
    }
  }
}

class RangeNotifier<T> extends ChangeNotifier {
  T? _begin;
  T? _end;

  RangeNotifier();

  factory RangeNotifier.init(T begin, T end) {
    return RangeNotifier<T>()
      .._begin = begin
      .._end = end;
  }

  T? get begin => _begin;

  T? get end => _end;

  void setBegin(T? begin) {
    if (_begin != begin) {
      _begin = begin;
      notifyListeners();
    }
  }

  void setEnd(T? end) {
    if (_end != end) {
      _end = end;
      notifyListeners();
    }
  }

  void setRange(T? begin, T? end) {
    if (_begin != begin || _end != end) {
      _begin = begin;
      _end = end;
      notifyListeners();
    }
  }

  @override
  String toString() => "${_begin.toString()}-${_end.toString()}";
}

class TickNotifier extends ChangeNotifier {
  DateTime _tick = DateTime.now();

  int get value => _tick.microsecondsSinceEpoch;

  void change() {
    _tick = DateTime.now();
    notifyListeners();
  }
}
