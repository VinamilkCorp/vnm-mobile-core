extension ObjectOptinalEx on Object? {
  T? parse<T>() => this is T ? this as T : null;
}
