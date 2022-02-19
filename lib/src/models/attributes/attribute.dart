import 'package:recase/recase.dart';

abstract class Attribute<T> {
  Attribute fromJson(String json);

  T toJson();

  Map<String, dynamic> toMap() => {
        this.toString().snakeCase: toJson(),
      };
}
