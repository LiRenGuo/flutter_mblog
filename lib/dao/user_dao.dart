import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';

import '../util/net_utils.dart';
import '../util/oauth.dart';

const USER_INFO_URL = "http://mblog.yunep.com/api/profile";

class UserDao{
  static Future<UserModel> getUserInfo() async {
    final response = await dio.get(USER_INFO_URL);
    if(response.statusCode == 200) {
      final responseData = response.data;
      print("response = ${responseData}");
      return UserModel.fromJson(responseData);
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
