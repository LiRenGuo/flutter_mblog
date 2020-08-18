import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';

import 'TimeMachineUtil.dart';

class TimeToSimple {

  static String timeToSimple(int time) {
    var now = DateTime.now();
    var d1 = DateTime.fromMillisecondsSinceEpoch(time);

    Map<String, String> nowWeekday = TimeMachineUtil.getWeeksDate(0);
    if (now.year == d1.year && now.month == d1.month && now.day == d1.day) { // 判断是否为今天
      return now.difference(d1).toString();
    } else if (now.year == d1.year &&
        now.month == d1.month &&
        (now.day - 1) == d1.day) { // 判断是否为昨天
      return "昨天";
    }

    // 判断是否在一周内
    String flag = "-1";
    nowWeekday.forEach((key, value) {
      var weekday = DateTime.parse(value);
      if (weekday.year == d1.year &&
          weekday.month == d1.month &&
          weekday.day == d1.day) {
        flag = value;
        return;
      }
    });
    if (flag != "-1") {
      return DateUtil.getWeekday(DateTime.parse(flag),languageCode: 'zh');
    }else{
      if (now.year == d1.year) {
        return  d1.month.toString()  + "-" + d1.day.toString();
      }else{
        return d1.year.toString() + "-" + d1.month.toString();
      }
    }
  }
}
