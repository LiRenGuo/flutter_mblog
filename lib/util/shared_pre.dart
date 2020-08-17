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
    String email = preferences.get(Constants.Shared_Email);
    String username = preferences.get(Constants.Shared_Username);
    String mobile = preferences.get(Constants.Shared_Mobile);
    String name = preferences.get(Constants.Shared_Name);
    String avatar = preferences.get(Constants.Shared_Avatar);
    return UserModel(
        mobile: mobile,
        email: email,
        username: username,
        avatar: avatar,
        name: name,
        );
  }

  static Future<String>  Shared_setUser(UserModel model) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Email, model.email);
    preferences.setString(Constants.Shared_Mobile, model.mobile);
    preferences.setString(Constants.Shared_Name, model.name);
    preferences.setString(Constants.Shared_Username, model.username);
    preferences.setString(Constants.Shared_Avatar, model.avatar);
  }

  static Future<String> Shared_deleteUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Email, null);
    preferences.setString(Constants.Shared_Mobile, null);
    preferences.setString(Constants.Shared_Name, null);
    preferences.setString(Constants.Shared_Username, null);
    preferences.setString(Constants.Shared_Avatar, null);
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

  static Future<String> Shared_setArticle(String data) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Article, data);

  }
  static Future<String> Shared_getArticle() async {
    var article;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    article = await preferences.getString(Constants.Shared_Article);
    return article;

  }

}
