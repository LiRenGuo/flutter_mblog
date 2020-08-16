import 'dart:convert';

import 'package:flutter_mblog/model/user.dart';
import 'package:flutter_mblog/pages/login_page.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:flutter/material.dart';

import 'Configs.dart';
import 'net_utils.dart';

class Oauth_2 {
  static final authorizationEndpoint = Uri.parse(Test.TokenUrl);
  static final identifier = "web";
  static final secret = "e25be7592b6a8a2c";

  static Future Login_oauth2(
      String username, String password, BuildContext context) async {
    try {
      var client = await oauth2.resourceOwnerPasswordGrant(
          authorizationEndpoint, username, password,
          identifier: identifier, basicAuth: true, secret: secret);
      String result = await client.read(Test.AuthServer);
      Map parsed = json.decode(result);
      print(result);
      print(">>>>>>刷新token"+client.credentials.refreshToken);
      Shared_pre.Shared_setUser(User.fromJson(parsed));
      Shared_pre.Shared_setToken(client.credentials.accessToken);
      Shared_pre.Shared_setResToken(client.credentials.refreshToken);
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  static ResToken(BuildContext context) {
    Shared_pre.Shared_getResToken().then((token) async {
      Map<String, dynamic> Params = {
        'grant_type': 'refresh_token',
        'refresh_token': '$token',
        'client_id': '$identifier',
        'client_secret': '$secret'
      };

      await NetUtils.postdata(Test.TokenUrl, params: Params).then((result) {
        if (result == 400 || result == 401) {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => LoginPage()), (route) => route == null);
        } else {
          Shared_pre.Shared_setToken(result['access_token']);
          Shared_pre.Shared_setResToken(result['refresh_token']);
        }
      });
    });
  }
}
