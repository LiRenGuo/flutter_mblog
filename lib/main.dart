import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/register_user.dart';
import 'package:flutter_mblog/navigator/tab_navigator.dart';
import 'package:flutter_mblog/pages/home_page.dart';
import 'package:flutter_mblog/pages/login_page.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;
import 'package:flutter_mblog/pages/register/register_password.dart';
import 'package:flutter_mblog/pages/register/rest_password_end_page.dart';
import 'package:flutter_mblog/pages/welcome_page.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

void main() async{
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  // 用于路由返回监听
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [MyApp.routeObserver],
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TabNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }


}

