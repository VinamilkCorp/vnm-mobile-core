import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../material/exception/exception.dart';
import '../global/localization.dart';

class DateTimeUtil {
  static final DateFormat vnDateTimeFormatter = DateFormat('HH:mm • dd/MM/y');
  static final DateFormat enDateTimeFormatter =
      DateFormat('h:mm a • MMM dd, y');

  static final DateFormat vnTimeFormatter = DateFormat('HH:mm');
  static final DateFormat enTimeFormatter = DateFormat('h:mm a');

  static final DateFormat vnDateFormatter = DateFormat('dd/MM/y');
  static final DateFormat enDateFormatter = DateFormat('MMM dd, y');

  static final DateFormat orderDateFormatter = DateFormat('dd/MM/yyyy');

  static String formatDatetime(BuildContext context, DateTime date) {
    String result = "";
    try {
      final Locale appLocale = Localizations.localeOf(context);
      if (appLocale.languageCode == "en") {
        result = enDateTimeFormatter.format(date);
      }
      result = vnDateTimeFormatter.format(date);
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    } finally {
      return result;
    }
  }

  static String formatDate(BuildContext context, DateTime date) {
    final Locale appLocale = Localizations.localeOf(context);
    if (appLocale.languageCode == "en") {
      return enDateFormatter.format(date);
    }

    return vnDateFormatter.format(date);
  }

  static getTime(BuildContext context, DateTime date) {
    return enTimeFormatter.format(date);
  }

  static getDayStr(BuildContext context, DateTime date) {
    if (isToday(date)) return Localization().locale.today;
    if (isYesterday(context, date)) return Localization().locale.yesterday;
    return formatDate(context, date);
  }

  static isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final aDate = DateTime(date.year, date.month, date.day);
    return aDate == today;
  }

  static isYesterday(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day - 1);

    final aDate = DateTime(date.year, date.month, date.day);
    return aDate == tomorrow;
  }

  static DateTime getStartOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static DateTime getEndOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day)
        .add(Duration(days: 1));
  }

  static DateTime mapOrderDate(String? orderDateStr) {
    if (orderDateStr != null && orderDateStr.isEmpty)
      return getStartOfDay(DateTime.now());
    DateTime value = getStartOfDay(DateTime.now());
    try {
      value = orderDateFormatter.parse(orderDateStr!);
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    } finally {
      return value;
    }
  }

  static double hoursBetween(DateTime from, DateTime to) {
    return (to.difference(from).inHours).toDouble();
  }

  static DateTime? parse(String? formattedString) {
    DateTime? value;
    try {
      if (formattedString == null) return null;
      value = DateTime.parse(formattedString);
    } catch (exception, stackTrace) {
      VNMException().capture(exception, stackTrace);
    } finally {
      return value;
    }
  }
}
