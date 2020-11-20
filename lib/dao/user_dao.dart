import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/util/Configs.dart';
import 'package:flutter_mblog/util/dio_error_process.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

import '../util/net_utils.dart';
import '../util/oauth.dart';

final USER_INFO_URL = "${Auth.ipaddress}/api/profile";
final EDIT_USERNAME_URL = "${Auth.ipaddress}/api/reset/username";
final USER_ID_INFO_URL = "${Auth.ipaddress}/api/user";
final USER_FOLLOWING_LIST = "${Auth.ipaddress}/api/user/following";
final GET_ID_BY_NAME = "${Auth.ipaddress}/api/user/name/";
final USER_FOLLOWERS = "${Auth.ipaddress}/api/user/followers/";
///
/// 用户接口
class UserDao {

  ///
  /// 获取用户信息
  static Future<UserModel> getUserInfo(BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.get(USER_INFO_URL, options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        return UserModel.fromJson(responseData);
      } else {
        throw Exception('loading data error.....');
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 根据userId获取用户信息
  static Future<UserModel> getUserInfoByUserId(
      String userid, BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response =
          await dio.get(USER_ID_INFO_URL + "/$userid", options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        return UserModel.fromJson(responseData);
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 保存用户信息
  static Future<void> saveUserInfo(
      BuildContext context, FormData formData) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response =
          await dio.post(USER_INFO_URL, data: formData, options: options);
      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 获取正在关注列表
  static Future<FollowModel> getFollowingList(
      String userId, BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      dio.options.connectTimeout = 3000;
      dio.options.receiveTimeout = 5000;
      final response = await dio.get(
          "$USER_FOLLOWING_LIST/$userId",
          options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        return FollowModel.fromJson(responseData);
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 获取关注者列表
  static Future<FollowModel> getFollowersList(
      String userId, BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      dio.options.connectTimeout = 3000;
      dio.options.receiveTimeout = 5000;
      final response = await dio.get(
          "$USER_FOLLOWERS$userId",
          options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        return FollowModel.fromJson(responseData);
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 根据UserId判断这个人是否有关注我
  static Future<bool> isFollowMy(BuildContext context, String userId) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      dio.options.connectTimeout = 5000;
      dio.options.receiveTimeout = 10000;
      final response = await dio.get(
          "${Auth.ipaddress}/user/isfollow/$userId",
          options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData;
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 修改用户名
  static Future<String> editUserName(
      BuildContext context, FormData formData) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response =
          await dio.post(EDIT_USERNAME_URL, data: formData, options: options);
      if (response.statusCode == 200) {
        return "success";
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 根据姓名获取userId
  static Future<String> getIdByName(String name, BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.get(GET_ID_BY_NAME + name, options: options);
      if (response.statusCode == 200) {
        return response.data;
      }
    } on DioError catch (e) {
      MyToast.show("该用户不存在");
      DioErrorProcess.dioError(context, e);
    }
  }
}
