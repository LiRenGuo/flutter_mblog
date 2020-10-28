import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/util/dio_error_process.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../util/net_utils.dart';


const USER_FOLLOW_URI = "http://mblog.yunep.com/api/follow/";

///
/// 关注Dao
class FollowDao{

  ///
  /// 关注接口
  static void follow(String userId,BuildContext context) async {
    try {
      String token =  await Shared_pre.Shared_getToken();
      UserModel userModel =  await Shared_pre.Shared_getUser();
      if (userModel.id == userId) {
        MyToast.show("不能关注自己");
        return;
      }
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.get(USER_FOLLOW_URI+"$userId",options: options);
      if(response.statusCode == 200) {
        MyToast.show("你成功关注了该用户");
      }
    }on DioError catch(e) {
      DioErrorProcess.dioError(context, e);
    }
  }


  ///
  /// 取消关注
  static void unfollow(String userId,BuildContext context) async {
    try {
      String token =  await Shared_pre.Shared_getToken();
      UserModel userModel =  await Shared_pre.Shared_getUser();
      if (userModel.id == userId) {
        MyToast.show("不能取消关注自己");
        return;
      }
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.delete(USER_FOLLOW_URI+"$userId",options: options);
      if(response.statusCode == 200) {
        MyToast.show("取消关注了该用户");
      }
    }on DioError catch(e) {
      DioErrorProcess.dioError(context, e);
    }
  }
}
