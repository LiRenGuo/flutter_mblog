import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/navigator/tab_navigator.dart';
import 'package:flutter_mblog/pages/home_page.dart';
import 'package:flutter_mblog/pages/login_page.dart';
import 'package:flutter_mblog/pages/welcome_page.dart';
import 'package:flutter_mblog/util/dio_error_process.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:flutter/material.dart';

import 'Configs.dart';
import 'net_utils.dart';

///
/// Oauth授权登陆
class Oauth_2 {
  static final authorizationEndpoint = Uri.parse(Auth.TokenUrl);
  static final identifier = "web";
  static final secret = "e25be7592b6a8a2c";

  ///
  /// Oauth登陆接口
  static Future Login_oauth2(
      String username, String password, BuildContext context) async {
    try {
      var client = await oauth2.resourceOwnerPasswordGrant(
          authorizationEndpoint, username, password,
          identifier: identifier, basicAuth: true, secret: secret);
      Uint8List result = await client.readBytes(Auth.AuthServer);
      Utf8Decoder utf8decoder = Utf8Decoder();
      Map parsed = json.decode(utf8decoder.convert(result));
      print(">>>>>>token获取" + client.credentials.accessToken);
      Shared_pre.Shared_setUser(UserModel.fromJson(parsed));
      Shared_pre.Shared_setToken(client.credentials.accessToken);
      Shared_pre.Shared_setResToken(client.credentials.refreshToken);
      return 'success';
    }  catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  ///
  /// 刷新Token接口
  static ResToken(BuildContext context,{bool isLogin = true}) {
    BuildContext mContext  = context;
    print("Token过期，重新刷新");
    Shared_pre.Shared_getResToken().then((token) {
      Map<String, dynamic> params = {
        'grant_type': 'refresh_token',
        'refresh_token': '$token',
        'client_id': '$identifier',
        'client_secret': '$secret'
      };
      Options options = Options(headers: {HttpHeaders.authorizationHeader:"Basic d2ViOmUyNWJlNzU5MmI2YThhMmM"});
      print("准备请求token");
      try {
        NetUtils.postdata(Auth.TokenUrl, params: params,options: options).then((result) {
          print("请求Token:${result}");
          if (result == 400 || result == 401) {
            Navigator.pushAndRemoveUntil(mContext, MaterialPageRoute(builder: (context) => WelcomePage()), (route) => route == null);
          } else {
            Shared_pre.Shared_setToken(result['access_token']);
            Shared_pre.Shared_setResToken(result['refresh_token']);
            if(isLogin) {
              Navigator.pushAndRemoveUntil(mContext,
                  MaterialPageRoute(builder: (context) => TabNavigator()), (route) => route == null);
            }
          }
        });
      }on DioError catch(e) {
        if(e.response.statusCode==401){//401代表refresh_token过期
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => WelcomePage()),
                (route) => route == null);
        }
      }
    });
   }
}
