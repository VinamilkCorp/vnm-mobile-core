import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';

import '../../material/style/color.dart';
import '../../material/widget/basic/radius_border_container.dart';
import '../../material/widget/button/button.dart';
import '../global/localization.dart';
import '../global/navigator.dart';

class CalendarUtil {
  static Future<DateTimeRange?> showByRange(
    BuildContext context, {
    required DateTimeRange initialValue,
    DateTime? lastDate,
  }) async {
    DateTimeRange? selected;
    return await showModalBottomSheet(
        context: context,
        backgroundColor: VNMColor.transparent(),
        builder: (context) {
          return RadiusBorderContainer(
            child: Column(
              children: [
                Expanded(
                    child: CalendarDatePicker2(
                  config: CalendarDatePicker2Config(
                      lastDate: lastDate,
                      calendarType: CalendarDatePicker2Type.range),
                  value: [initialValue.start, initialValue.end],
                  onValueChanged: (dates) {
                    selected = null;
                    if (dates.length > 0) {
                      if (dates.first != null && dates.last != null)
                        selected = DateTimeRange(
                            start: dates.first!, end: dates.last!);
                    }
                  },
                )),
                Row(
                  children: [
                    Expanded(
                      child: VNMButton.primary(
                        Localization().locale.agree,
                        onPressed: () => VNMNavigator().pop(selected),
                      ).bottoming,
                    )
                  ],
                )
              ],
            ),
          );
        });
  }
}
