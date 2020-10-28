import 'dart:convert';

import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Configs.dart';

/// *
/// 本地存储类
class Shared_pre {

  /// 获取Token
  static Future<String> Shared_getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var Token = await preferences.getString(Shared.Shared_Token);
    return Token;
  }

  /// 设置Token
  static Future<String> Shared_setToken(String token) async {
    var Token;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Shared.Shared_Token, token);
    return Token;
  }

  /// 删除Token
  static Future<String> Shared_deleteToken() async {
    var Token;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Shared.Shared_Token, null);
    return Token;
  }

  /// 获取用户信息
  static Future<UserModel> Shared_getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.get(Shared.Shared_Id);
    int ctime = preferences.get(Shared.Shared_Ctime) ?? 0;
    String email = preferences.get(Shared.Shared_Email) ?? "";
    String username = preferences.get(Shared.Shared_Username);
    String mobile = preferences.get(Shared.Shared_Mobile);
    String name = preferences.get(Shared.Shared_Name) ?? "登陆";
    String avatar = preferences.get(Shared.Shared_Avatar) ?? "https://zzm888.oss-cn-shenzhen.aliyuncs.com/avatar-default.png";
    String banner = preferences.get(Shared.Shared_Banner);
    String followers = preferences.get(Shared.Shared_Followers) ?? "0";
    String following = preferences.get(Shared.Shared_Following) ?? "0";
    return UserModel(
        id: id,
        mobile: mobile,
        email: email,
        username: username,
        avatar: avatar,
        banner: banner,
        name: name,
        ctime: ctime,
        followers: int.parse(followers),
        following: int.parse(following));
  }

  /// 设置用户
  static Future<String> Shared_setUser(UserModel model) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Shared.Shared_Email, model.email);
    preferences.setString(Shared.Shared_Mobile, model.mobile);
    preferences.setString(Shared.Shared_Name, model.name);
    preferences.setString(Shared.Shared_Username, model.username);
    preferences.setString(Shared.Shared_Avatar, model.avatar);
    preferences.setString(Shared.Shared_Banner, model.banner);
    preferences.setString(Shared.Shared_Id, model.id);
    preferences.setString(Shared.Shared_Following, model.following.toString());
    preferences.setString(Shared.Shared_Followers, model.followers.toString());
    preferences.setInt(Shared.Shared_Ctime, model.ctime);
  }

  /// 删除用户
  static Future<String> Shared_deleteUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Shared.Shared_Email, null);
    preferences.setString(Shared.Shared_Mobile, null);
    preferences.setString(Shared.Shared_Name, null);
    preferences.setString(Shared.Shared_Username, null);
    preferences.setString(Shared.Shared_Avatar, null);
  }

  /// 删除用户名
  static Future<String> Shared_deleteUserName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Shared.Shared_Username, null);
  }

  /// 设置用户名
  static Future<String> Shared_setUserName(String username) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Shared.Shared_Username, username);
  }

  /// 删除电话号码
  static Future<String> Shared_deleteMobile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Shared.Shared_Mobile, null);
  }

  /// 设置电话号码
  static Future<String> Shared_setMobile(String mobile) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Shared.Shared_Mobile, mobile);
  }

  /// 获取刷新Token
  static Future<String> Shared_getResToken() async {
    var Token;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Token = await preferences.getString(Shared.Shared_ResToken);
    return Token;
  }

  /// 设置刷新Token
  static Future<String> Shared_setResToken(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Shared.Shared_ResToken, token);
  }

  /// 删除刷新Token
  static Future<String> Shared_deleteResToken() async {
    var Token;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Shared.Shared_ResToken, null);
    return Token;
  }

  /// 设置首页帖子信息
  static Future<String> Shared_setTwitter(PostModel postModel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Shared.Shared_Twitter, json.encode(postModel));
  }

  /// 获取首页帖子信息
  static Future<PostModel> Shared_getTwitter() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String twitterData = preferences.getString(Shared.Shared_Twitter);
    PostModel newPostModel;
    if (twitterData != null) {
      newPostModel = PostModel.fromJson(json.decode(twitterData));
    }
    return Future.value(newPostModel);
  }

  /// 删除首页帖子信息
  static Future<String> SharedDeleteTwitter() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Shared.Shared_Twitter, null);
  }
}
