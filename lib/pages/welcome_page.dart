import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mblog/navigator/tab_navigator.dart';
import 'package:flutter_mblog/pages/home_page.dart';
import 'package:flutter_mblog/pages/login_page.dart';
import 'package:flutter_mblog/pages/register/register_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/oauth.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool isok = false;
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  //平台消息是异步的，所以我们用异步方法初始化。
  Future<Null> initConnectivity() async {
    var connectionStatus;
    //平台消息可能会失败，因此我们使用Try/Catch PlatformException。
    try {
      connectionStatus = (await _connectivity.checkConnectivity());
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }
    // 如果在异步平台消息运行时从树中删除了该小部件，
    // 那么我们希望放弃回复，而不是调用setstate来更新我们不存在的外观。
    if (connectionStatus == ConnectivityResult.mobile)
      Fluttertoast.showToast(
          msg: "正在使用流量",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0XF20A2F4),
          textColor: Colors.white,
          fontSize: 16.0
      );
    else if (connectionStatus == ConnectivityResult.wifi)
      Fluttertoast.showToast(
          msg: "WIFI",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0XF20A2F4),
          textColor: Colors.white,
          fontSize: 16.0
      );
    else if (connectionStatus == ConnectivityResult.none)
      Fluttertoast.showToast(
          msg: "unknown",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0XF20A2F4),
          textColor: Colors.white,
          fontSize: 16.0
      );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    isLogin();
  }

  isLogin()async{
    String token =  await Shared_pre.Shared_getToken();
    if (token != null) {
      Oauth_2.ResToken(context);
    }
    setState(() {
      isok = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: isok ? Container(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Expanded(
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
              Expanded(
                child: Container(
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
                ),
              )
            ],
          ),
        ) : Container()
      ),
    );
  }
}
