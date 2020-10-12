import 'dart:convert';

import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Configs.dart';

class Shared_pre {
  static Future<String> Shared_getToken() async {
    var Token;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Token = await preferences.getString(Constants.Shared_Token);
    return Token;
  }

  static Future<String> Shared_getId() async {
    var id;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString(Constants.Shared_Id);
    return id;
  }

  static Future<String> Shared_setToken(String token) async {
    var Token;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Token, token);
    return Token;
  }

  static Future<String> Shared_deleteToken() async {
    var Token;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Token, null);
    return Token;
  }

  static Future<UserModel> Shared_getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.get(Constants.Shared_Id);
    int ctime = preferences.get(Constants.Shared_Ctime) ?? 0;
    String email = preferences.get(Constants.Shared_Email) ?? "";
    String username = preferences.get(Constants.Shared_Username);
    String mobile = preferences.get(Constants.Shared_Mobile);
    String name = preferences.get(Constants.Shared_Name) ?? "登陆";
    String avatar = preferences.get(Constants.Shared_Avatar) ??
        "https://zzm888.oss-cn-shenzhen.aliyuncs.com/avatar-default.png";
    String banner = preferences.get(Constants.Shared_Banner);
    String followers = preferences.get(Constants.Shared_Followers) ?? "0";
    String following = preferences.get(Constants.Shared_Following) ?? "0";
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

  static Future<String> Shared_setUser(UserModel model) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Email, model.email);
    preferences.setString(Constants.Shared_Mobile, model.mobile);
    preferences.setString(Constants.Shared_Name, model.name);
    preferences.setString(Constants.Shared_Username, model.username);
    preferences.setString(Constants.Shared_Avatar, model.avatar);
    preferences.setString(Constants.Shared_Banner, model.banner);
    preferences.setString(Constants.Shared_Id, model.id);
    preferences.setString(Constants.Shared_Following, model.following.toString());
    preferences.setString(Constants.Shared_Followers, model.followers.toString());
    preferences.setInt(Constants.Shared_Ctime, model.ctime);
  }

  static Future<String> Shared_deleteUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Email, null);
    preferences.setString(Constants.Shared_Mobile, null);
    preferences.setString(Constants.Shared_Name, null);
    preferences.setString(Constants.Shared_Username, null);
    preferences.setString(Constants.Shared_Avatar, null);
  }

  static Future<String> Shared_deleteUserName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Username, null);
  }

  static Future<String> Shared_setUserName(String username) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Username, username);
  }

  static Future<String> Shared_deleteMobile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Mobile, null);
  }

  static Future<String> Shared_setMobile(String mobile) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Mobile, mobile);
  }

  static Future<String> Shared_getResToken() async {
    var Token;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Token = await preferences.getString(Constants.Shared_ResToken);
    return Token;
  }

  static Future<String> Shared_setResToken(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_ResToken, token);
  }

  static Future<String> Shared_deleteResToken() async {
    var Token;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_ResToken, null);
    return Token;
  }

  static Future<String> Shared_setTwitter(PostModel postModel) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Twitter, json.encode(postModel));
  }

  static Future<String> Shared_setNewTwitter(PostModel postModel)async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_New_Twitter, json.encode(postModel));
  }

  static Future<PostModel> Shared_getTwitter() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String twitterData = preferences.getString(Constants.Shared_Twitter);
    PostModel newPostModel;
    if (twitterData != null) {
      newPostModel = PostModel.fromJson(json.decode(twitterData));
    }
    return Future.value(newPostModel);
  }

  static Future<PostModel> Shared_getNewTwitter() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String twitterData = preferences.getString(Constants.Shared_New_Twitter);
    PostModel newPostModel;
    if (twitterData != null) {
      newPostModel = PostModel.fromJson(json.decode(twitterData));
    }
    return Future.value(newPostModel);
  }

  static Future<String> SharedDeleteTwitter() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Twitter, null);
  }

  static Future<String> SharedDeleteNewTwitter() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_New_Twitter, null);
  }
}
