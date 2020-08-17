import 'package:flutter/material.dart';

class TimeUtil {
  static final min = 60;
  static final hour = min * 60;
  static final day = hour * 24;
  static final mon = day * 30;
  static final years = 12 * mon;
  

  static setHours(hours) {
    if (hours < 10) {
      return '0${hours}';
    } else {
      return '${hours}';
    }
  }

  static String getNowtime() {
    DateTime dateTime = DateTime.now();
    var hour = dateTime.hour;
    var min = dateTime.minute;
    return '更新于${setHours(hour)}:${min}';
  }

  static String parse(String timestamp) {
    var nowa = DateTime.now();
    int dataTime = int.parse(timestamp);
    var data = DateTime.fromMillisecondsSinceEpoch(dataTime, isUtc: true);
    //debugPrint("传过来的时间是 ${data}");
    var c = nowa.difference(data).inSeconds;
    // print(c);
    if (c > years) {
      return ('${(c / years).toInt()}年前');
    } else if (c > mon) {
      return ('${data.toIso8601String().substring(5, 10)}');
    } else if (c > day) {
      return ('${data.toIso8601String().substring(5, 10)}');
    } else if (c > hour) {
      return ('${(c / hour).toInt()}小时前');
    } else if (c > min) {
      return ('${(c / min).toInt()}分前');
    } else {
      return ('${c}秒前');
    }
  }

  static String readDataTime(int timestamp) {
    //DateTime dateTime = DateTime.now();
    var data = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: false);
    String hours;
    String times;
    String years;
    String months;
    String days;
    hours = data.hour.toString();
    times = data.minute.toString();
    years = data.year.toString();
    months = data.month.toString();
    days = data.day.toString();
    return ("$hours:$times · $years/$months/$days");
  }
}
