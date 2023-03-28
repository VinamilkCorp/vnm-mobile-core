extension IntIfNull on int? {
  int ifNull([int defaultValue = 0]) => this == null ? defaultValue : this!;
}

extension StringIfNull on String? {
  String ifNull([String defaultValue = '']) =>
      this == null ? defaultValue : this!;

  String ifEmpty(String text) => this == '' ? text : this!;

  String ifNullOrEmpty(String text) =>
      this == null || this == '' ? text : this!;
}
