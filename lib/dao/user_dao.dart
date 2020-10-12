import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/util/dio_error_process.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

import '../util/net_utils.dart';
import '../util/oauth.dart';

const USER_INFO_URL = "http://mblog.yunep.com/api/profile";
const EDIT_USERNAME_URL = "http://mblog.yunep.com/api/reset/username";
const USER_ID_INFO_URL = "http://mblog.yunep.com/api/user";
const USER_FOLLOWING_LIST = "http://mblog.yunep.com/api/user/following";

class UserDao{
  static Future<UserModel> getUserInfo(BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.get(USER_INFO_URL, options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        print("response = ${responseData}");
        return UserModel.fromJson(responseData);
      } else {
        throw Exception('loading data error.....');
      }
    } on DioError catch (e) {
      print("重新获取");
      DioErrorProcess.dioError(context, e);
      /*if (e.response.statusCode == 401) {
        Oauth_2.ResToken(context);
      }*/
    }
  }

  static Future<UserModel> getUserInfoByUserId(
      String userid, BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response =
      await dio.get(USER_ID_INFO_URL + "/$userid", options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        print("response = ${responseData}");
        return UserModel.fromJson(responseData);
      }
    }on DioError catch(e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  static Future<void> saveUserInfo(BuildContext context,FormData formData) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.post(USER_INFO_URL, data: formData,options: options);
      if (response.statusCode == 200) {
        return response.data;
      }
    }on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  static Future<FollowModel> getFollowingList(
      String userId, BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response =
          await dio.get("http://mblog.yunep.com/api/user/following/$userId",options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        return FollowModel.fromJson(responseData);
      } else {
        throw Exception("loading data error");
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  static Future<FollowModel> getFollowersList(
      String userId, BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      dio.options.connectTimeout = 5000;
      dio.options.receiveTimeout = 10000;
      final response = await dio.get("http://mblog.yunep.com/api/user/followers/$userId",options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        return FollowModel.fromJson(responseData);
      } else {
        throw Exception("loading data error");
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  static Future<bool> isFollowMy(BuildContext context,String userId)async{
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      dio.options.connectTimeout = 5000;
      dio.options.receiveTimeout = 10000;
      final response = await dio.get("http://mblog.yunep.com/user/isfollow/$userId",options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData;
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  static Future<String> editUserName(BuildContext context,FormData formData) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.post(EDIT_USERNAME_URL, data: formData,options: options);
      if (response.statusCode == 200) {
        return "success";
      }
    }on DioError catch(e) {
      DioErrorProcess.dioError(context, e);
    }
  }
}
