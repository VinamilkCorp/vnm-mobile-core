abstract class Mappable<T> {
  Mappable();

  T fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson();
}
