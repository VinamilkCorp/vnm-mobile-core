import 'route.dart';

class VNMTrackingConfig {
  static VNMTrackingConfig _i = VNMTrackingConfig._();
  Function(String label)? logButton;
  Function(AppRoute appRoute, Object? args)? logRoute;

  VNMTrackingConfig._();

  factory VNMTrackingConfig() => _i;

  void initialize(
      {Function(String label)? logButton,
      Function(AppRoute appRoute, Object? args)? logRoute}) {
    this.logButton = logButton;
    this.logRoute = logRoute;
  }
}
