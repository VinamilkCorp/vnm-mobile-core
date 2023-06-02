import 'package:flutter/material.dart';

typedef AppRouteBuilder = Widget Function(Object? args);

class VNMAppRoute {
  final String code;
  final AppRouteBuilder builder;

  VNMAppRoute(this.code, this.builder);
}
