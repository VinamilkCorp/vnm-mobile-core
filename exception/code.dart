import 'exception.dart';
import 'message_exception.dart';
import 'server_exceptions.dart';

enum ExceptionCode {
  RS01404,
  RS01521,
  AS01403,
  VS01403,
  VS02401,
  VS03401,
  AU05400
}

extension ExceptionCodeExtension on ExceptionCode {
  MessageException get exception {
    switch (this) {
      case ExceptionCode.RS01404:
        return RS01404Exception();
      case ExceptionCode.RS01521:
        return RS01521Exception();
      case ExceptionCode.AS01403:
        return AS01403Exception();
      case ExceptionCode.VS01403:
        return VS01403Exception();
      case ExceptionCode.VS02401:
        return VS02401Exception();
      case ExceptionCode.VS03401:
        return VS03401Exception();
      case ExceptionCode.AU05400:
        return AU05400Exception();
    }
  }
}

extension ExceptionCodeListEx on Iterable<ExceptionCode> {
  ExceptionCode byNameIfNull(String name, ExceptionCode defaultValue) {
    ExceptionCode value = defaultValue;
    try {
      value = byName(name);
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    } finally {
      return value;
    }
  }
}
