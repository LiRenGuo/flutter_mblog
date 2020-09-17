import 'package:flutter/material.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text("设置过期Token"),
          onPressed: (){
            Shared_pre.Shared_setToken("11111");
          },
        ),
      ),
    );
  }
}
