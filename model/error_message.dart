import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../global/localization.dart';

class ErrorMessageConfig {
  String? code;
  Text? text;

  String get message {
    AppLocalizations locale = Localization().locale;
    if (locale.localeName == "vi") {
      return text?.vi ?? locale.server_error_message;
    } else {
      return text?.en ?? locale.server_error_message;
    }
  }

  ErrorMessageConfig({this.code, this.text});

  ErrorMessageConfig.fromJson(Map<String, dynamic> json) {
    if (json["code"] is String) {
      code = json["code"];
    }
    if (json["text"] is Map) {
      text = json["text"] == null ? null : Text.fromJson(json["text"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["code"] = code;
    if (text != null) {
      _data["text"] = text?.toJson();
    }
    return _data;
  }

  ErrorMessageConfig copyWith({
    String? code,
    Text? text,
  }) =>
      ErrorMessageConfig(
        code: code ?? this.code,
        text: text ?? this.text,
      );
}

class Text {
  String? vi;
  String? en;

  Text({this.vi, this.en});

  Text.fromJson(Map<String, dynamic> json) {
    if (json["vi"] is String) {
      vi = json["vi"];
    }
    if (json["en"] is String) {
      en = json["en"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["vi"] = vi;
    _data["en"] = en;
    return _data;
  }

  Text copyWith({
    String? vi,
    String? en,
  }) =>
      Text(
        vi: vi ?? this.vi,
        en: en ?? this.en,
      );
}
