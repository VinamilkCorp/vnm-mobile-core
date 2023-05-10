abstract class Mappable<T> {
  Mappable();

  Map<String, dynamic> toJson();

  T fromJson(Map<String, dynamic> json);
}
