import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
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
      if (e.response.statusCode == 401) {
        Oauth_2.ResToken(context);
      }
    }
  }

  static Future<UserModel> getUserInfoByUserId(
      String userid, BuildContext context) async {
    String token = await Shared_pre.Shared_getToken();
    Options options = Options(headers: {'Authorization': 'Bearer $token'});
    final response =
        await dio.get(USER_ID_INFO_URL + "/$userid", options: options);
    if (response.statusCode == 200) {
      final responseData = response.data;
      print("response = ${responseData}");
      return UserModel.fromJson(responseData);
    } else {
      throw Exception('loading data error.....');
    }
  }

  static Future<void> saveUserInfo(FormData formData) async {
    String token = await Shared_pre.Shared_getToken();
    Options options = Options(headers: {'Authorization': 'Bearer $token'});
    final response = await dio.post(USER_INFO_URL, data: formData,options: options);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception("save info error....");
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
      print("e1 ${e.response.statusCode}");
    }
  }

  static Future<FollowModel> getFollowersList(
      String userId, BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response =
          await dio.get("http://mblog.yunep.com/api/user/followers/$userId",options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        return FollowModel.fromJson(responseData);
      } else {
        throw Exception("loading data error");
      }
    } on DioError catch (e) {
      print("e ${e.response.statusCode}");
    }
  }

  static Future<String> editUserName(FormData formData) async {
    String token = await Shared_pre.Shared_getToken();
    Options options = Options(headers: {'Authorization': 'Bearer $token'});
    final response = await dio.post(EDIT_USERNAME_URL, data: formData,options: options);
    if (response.statusCode == 200) {
      return "success";
    } else {
      throw Exception("save info error....");
    }
  }
}
