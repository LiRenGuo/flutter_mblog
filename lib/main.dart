import 'package:flutter/material.dart';
import 'package:flutter_mblog/navigator/tab_navigator.dart';
import 'package:flutter_mblog/pages/edit_mine_page.dart';
import 'package:flutter_mblog/pages/login_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SafeArea(
        child: LoginPage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

