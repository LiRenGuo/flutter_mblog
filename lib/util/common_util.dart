import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonUtil {
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