import 'package:common_utils/common_utils.dart';

class TimeMachineUtil{

  /// 当前时间 过去/未来 某个周的周一和周日
  static Map<String, String> getWeeksDate(int weeks) {
    Map<String, String> mapTime = new Map();
    DateTime now = new DateTime.now();
    int weekday = now.weekday; //今天周几

    var sunDay = getTimestampLatest(false, 7 - weekday + weeks * 7); //周末
    var satDay = getTimestampLatest(false, 6 - weekday + weeks * 6); //周六
    var friDay = getTimestampLatest(false, 5 - weekday + weeks * 6); //周无
    var thuDay = getTimestampLatest(false, 4 - weekday + weeks * 6); //周四
    var wedDay = getTimestampLatest(false, 3 - weekday + weeks * 6); //周三
    var tueDay = getTimestampLatest(false, 2 - weekday + weeks * 6); //周二
    var monDay = getTimestampLatest(true, -weekday + 1 + weeks * 7); //周一

    mapTime['sunDay'] =  DateUtil.formatDate(
        DateTime.fromMillisecondsSinceEpoch(sunDay,isUtc: true),
        format: 'yyyy-MM-dd'); //周日 时间格式化
    mapTime['satDay'] = DateUtil.formatDate(
        DateTime.fromMillisecondsSinceEpoch(satDay,isUtc: true),
        format: 'yyyy-MM-dd'); //周六 时间格式化
    mapTime['friDay'] = DateUtil.formatDate(
        DateTime.fromMillisecondsSinceEpoch(friDay,isUtc: true),
        format: 'yyyy-MM-dd'); //周五 时间格式化
    mapTime['thuDay'] = DateUtil.formatDate(
        DateTime.fromMillisecondsSinceEpoch(thuDay,isUtc: true),
        format: 'yyyy-MM-dd'); //周四 时间格式化
    mapTime['wedDay'] = DateUtil.formatDate(
        DateTime.fromMillisecondsSinceEpoch(wedDay,isUtc: true),
        format: 'yyyy-MM-dd'); //周三 时间格式化
    mapTime['tueDay'] = DateUtil.formatDate(
        DateTime.fromMillisecondsSinceEpoch(tueDay,isUtc: true),
        format: 'yyyy-MM-dd'); //周二 时间格式化
    mapTime['monDay'] = DateUtil.formatDate(
        DateTime.fromMillisecondsSinceEpoch(monDay,isUtc: true),
        format: 'yyyy-MM-dd'); //周一 时间格式化
    print('某个周的周一和周日：$mapTime');
    return mapTime;
  }


  /// phase : 是零点还是23:59:59
  static int getTimestampLatest(bool phase, int day) {
    String newHours;
    DateTime now = new DateTime.now();
    DateTime sixtyDaysFromNow = now.add(new Duration(days: day));
    String formattedDate = DateUtil.formatDate(sixtyDaysFromNow, format: 'yyyy-MM-dd');
    if (phase) {
      newHours = formattedDate + ' 00:00:00';
    } else {
      newHours = formattedDate + ' 23:59:59';
    }
    DateTime newDate = DateTime.parse(newHours);
    int timeStamp = newDate.millisecondsSinceEpoch ;
    return timeStamp;
  }
}