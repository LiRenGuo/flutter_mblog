import 'package:flutter_mblog/model/user.dart';
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

  static Future<User> Shared_getUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String email = preferences.get(Constants.Shared_Email);
    String name = preferences.get(Constants.Shared_Name);
    String mobile = preferences.get(Constants.Shared_Mobile);
    return User(
        mobile: mobile,
        email: email,
        username: name,
        );
  }

  static Future<String>  Shared_setUser(User name) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Email, name.email);
    preferences.setString(Constants.Shared_Mobile, name.mobile);
    preferences.setString(Constants.Shared_Name, name.username);
  }

  static Future<String> Shared_deleteUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(Constants.Shared_Email, null);
    preferences.setString(Constants.Shared_Mobile, null);
    preferences.setString(Constants.Shared_Name, null);
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
