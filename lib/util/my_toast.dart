import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyToast {
  static show(String msg, {toastLength = Toast.LENGTH_SHORT, gravity = ToastGravity.BOTTOM, backgroundColor = Colors.grey, textColor = Colors.white, fontSize = 16.0}) {
    return Fluttertoast.showToast(
        msg: msg,
        toastLength: toastLength,
        gravity: gravity,
        timeInSecForIosWeb: 1,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize);
  }
}