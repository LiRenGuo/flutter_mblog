import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

import '../util/net_utils.dart';
import '../util/oauth.dart';

const USER_INFO_URL = "http://mblog.yunep.com/api/profile";
const USER_ID_INFO_URL = "http://mblog.yunep.com/api/user";
const USER_FOLLOWING_LIST = "http://mblog.yunep.com/api/user/following";

class UserDao{
  static Future<UserModel> getUserInfo(BuildContext context) async {
    try {
      String token =  await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.get(USER_INFO_URL,options: options);
      if(response.statusCode == 200) {
        final responseData = response.data;
        print("response = ${responseData}");
        return UserModel.fromJson(responseData);
      } else {
        throw Exception('loading data error.....');
      }
    }on DioError catch(e) {
      print("重新获取");
      if (e.response.statusCode == 401) {
        Oauth_2.ResToken(context);
      }
    }
  }

  static Future<UserModel> getUserInfoByUserId(String userid,BuildContext context) async {
    String token =  await Shared_pre.Shared_getToken();
    Options options = Options(headers: {'Authorization': 'Bearer $token'});
    final response = await dio.get(USER_ID_INFO_URL + "/$userid",options: options);
    if(response.statusCode == 200) {
      final responseData = response.data;
      print("response = ${responseData}");
      return UserModel.fromJson(responseData);
    }else {
      throw Exception('loading data error.....');
    }
  }

  static Future<void> saveUserInfo(FormData formData)async {
    final response = await dio.post(USER_INFO_URL, data: formData);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception("save info error....");
    }
  }

  static Future<FollowModel> getFollowingList(String userId,BuildContext context) async{
    try {
      final response =  await dio.get("http://mblog.yunep.com/api/user/following/$userId");
      if (response.statusCode == 200) {
        final responseData = response.data;
        return FollowModel.fromJson(responseData);
      }else{
        throw Exception("loading data error");
      }
    }on DioError catch(e) {
      print(e.toString());
      print(e.response.statusCode);
      if (e.response.statusCode == 401) {
        Oauth_2.ResToken(context);
      }
    }
  }

  static Future<FollowModel> getFollowersList(String userId,BuildContext context)async{
    try {
      final response =  await dio.get("http://mblog.yunep.com/api/user/followers/$userId");
      if (response.statusCode == 200) {
        final responseData = response.data;
        return FollowModel.fromJson(responseData);
      }else{
        throw Exception("loading data error");
      }
    }on DioError catch(e) {
      print(e.toString());
      print(e.response.statusCode);
      if (e.response.statusCode == 401) {
        Oauth_2.ResToken(context);
      }
    }
  }
}
