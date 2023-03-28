import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MountedChangeNotifier extends ChangeNotifier {
  void notify(BuildContext context) {
    if (context.mounted) notifyListeners();
  }
}

class IntNotifier extends MountedChangeNotifier {
  int? _value;

  int? get value => _value;

  set value(int? value) => _value = value;

  void setValue(BuildContext context, int? value) {
    if (_value != value) {
      _value = value;
      notify(context);
    }
  }
}

class DoubleNotifier extends MountedChangeNotifier {
  double? _value;

  double? get value => _value;

  set value(double? value) => _value = value;

  void setValue(BuildContext context, double? value) {
    if (_value != value) {
      _value = value;
      notify(context);
    }
  }
}

class BoolNotifier extends MountedChangeNotifier {
  bool? _value;

  bool get isTrue => _value == true;

  bool get isFalse => _value == false;

  bool? get value => _value;

  set value(bool? value) => _value = value;

  void setValue(BuildContext context, bool? value) {
    if (_value != value) {
      _value = value;
      notify(context);
    }
  }
}

class ObjectNotifier<T> extends MountedChangeNotifier {
  T? _value;

  T? get value => _value;

  set value(T? value) => _value = value;

  void setValue(BuildContext context, T? value) {
    if (_value != value) {
      _value = value;
      notify(context);
    }
  }
}

class RangeNotifier<T> extends MountedChangeNotifier {
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

  void setBegin(BuildContext context, T? begin) {
    if (_begin != begin) {
      _begin = begin;
      notify(context);
    }
  }

  void setEnd(BuildContext context, T? end) {
    if (_end != end) {
      _end = end;
      notify(context);
    }
  }

  void setRange(BuildContext context, T? begin, T? end) {
    if (_begin != begin || _end != end) {
      _begin = begin;
      _end = end;
      notify(context);
    }
  }

  @override
  String toString() => "${_begin.toString()}-${_end.toString()}";
}

class TickNotifier extends MountedChangeNotifier {
  DateTime _tick = DateTime.now();

  int get value => _tick.microsecondsSinceEpoch;

  void change(BuildContext context) {
    _tick = DateTime.now();
    notify(context);
  }
}

extension ChangeNotifierCreator on ChangeNotifier {
  ChangeNotifierProvider create<T extends ChangeNotifier>() =>
      ChangeNotifierProvider<T>(create: (_) => this as T);
}
