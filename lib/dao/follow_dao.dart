import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/util/dio_error_process.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../util/net_utils.dart';
import '../util/oauth.dart';

const USER_FOLLOW_URI = "http://mblog.yunep.com/api/follow/";

class FollowDao{
  static void follow(String userId,BuildContext context) async {
    try {
      String token =  await Shared_pre.Shared_getToken();
      UserModel userModel =  await Shared_pre.Shared_getUser();
      if (userModel.id == userId) {
        Fluttertoast.showToast(
            msg: "不能关注自己",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      }
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.get(USER_FOLLOW_URI+"$userId",options: options);
      if(response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "你成功关注了该用户",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0XF20A2F4),
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }on DioError catch(e) {
      DioErrorProcess.dioError(context, e);
    }
  }


  static void unfollow(String userId,BuildContext context) async {
    try {
      String token =  await Shared_pre.Shared_getToken();
      UserModel userModel =  await Shared_pre.Shared_getUser();
      if (userModel.id == userId) {
        Fluttertoast.showToast(
            msg: "不能关注自己",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      }
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.delete(USER_FOLLOW_URI+"$userId",options: options);
      if(response.statusCode == 200) {
        final responseData = response.data;
        print("response = ${responseData}");
        Fluttertoast.showToast(
            msg: "取消关注了该用户",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0XF20A2F4),
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }on DioError catch(e) {
      DioErrorProcess.dioError(context, e);
    }
  }
}
