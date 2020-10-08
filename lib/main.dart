import 'package:flutter/material.dart';
import 'package:flutter_mblog/navigator/tab_navigator.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

void main() async{
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  // 用于路由返回监听
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorObservers: [MyApp.routeObserver],
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

