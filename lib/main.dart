import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_mblog/navigator/tab_navigator.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  FlutterDownloader.initialize(debug: false);
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
class MyApp extends StatelessWidget {
  // 用于路由返回监听
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mblog app',
      navigatorObservers: [MyApp.routeObserver],
      navigatorKey: navigatorKey,
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

