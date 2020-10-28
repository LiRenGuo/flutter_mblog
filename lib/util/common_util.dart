import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// 通用工具类
class CommonUtil {

  ///
  /// 显示中间加载
  static Future<Null> showLoadingDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return new Material(
              color: Colors.transparent,
              child: WillPopScope(
                  onWillPop: () => new Future.value(true),
                  child: Center(
                    child: new CircularProgressIndicator(),
                  )));
        });
  }
}