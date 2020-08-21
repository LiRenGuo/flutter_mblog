import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

import '../util/net_utils.dart';
import '../util/oauth.dart';

const USER_INFO_URL = "http://mblog.yunep.com/api/profile";
const USER_ID_INFO_URL = "http://mblog.yunep.com/api/user";

class UserDao{
  static Future<UserModel> getUserInfo(BuildContext context) async {
    String token =  await Shared_pre.Shared_getToken();
    Options options = Options(headers: {'Authorization': 'Bearer $token'});
    final response = await dio.get(USER_INFO_URL,options: options);
    if(response.statusCode == 200) {
      final responseData = response.data;
      print("response = ${responseData}");
      return UserModel.fromJson(responseData);
    }else if(response.statusCode == 401){
      Oauth_2.ResToken(context);
    } else {
      throw Exception('loading data error.....');
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
    }else if(response.statusCode == 401){
      Oauth_2.ResToken(context);
    } else {
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
}
