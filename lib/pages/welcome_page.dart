import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_mblog/pages/login_page.dart';
import 'package:flutter_mblog/pages/register/register_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/oauth.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(bottom: AdaptiveTools.setPx(100)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text("查看学校正在发生的新鲜事",style: TextStyle(fontSize: AdaptiveTools.setPx(18),fontWeight: FontWeight.bold),),
                      ),
                      Container(
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          color: Colors.blue,
                          child: Center(
                            child: Text("创建账号",style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white),),
                          ),
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                          },
                        ),
                        width: AdaptiveTools.setPx(300),
                        height: AdaptiveTools.setPx(35),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: <Widget>[
                    Text("已有账号？",style: TextStyle(fontSize: 16),),
                    InkWell(
                      child: Text("登陆",style: TextStyle(fontSize: 16,color: Colors.blue),),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}
