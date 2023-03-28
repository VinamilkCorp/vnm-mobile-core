extension MapEx on Map? {
  T? get<T>(String key) =>
      this == null ? null : (this![key] is T ? this![key] as T : null);
}
