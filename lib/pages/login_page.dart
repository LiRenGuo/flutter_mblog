import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/navigator/tab_navigator.dart';
import 'package:flutter_mblog/pages/register/reset_password_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/common_util.dart';
import 'package:flutter_mblog/util/image_process_tools.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/oauth.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'register/register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final textTips = TextStyle(fontSize: 16.0, color: Colors.black);
  final hintTips = TextStyle(fontSize: 16.0, color: Colors.black);

  TextEditingController _unameController = new TextEditingController();
  TextEditingController _pwdController = new TextEditingController();
  bool pwdShow = false; //密码是否显示明文
  final GlobalKey _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unameController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('登录', style: TextStyle(color: Colors.blue)),
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  "登陆你的账号",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
                padding: EdgeInsets.all(20),
              ),
              Container(
                child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "账号",
                      hintText: "请输入手机号/学号/工号",
                      prefixIcon: Icon(Icons.person),
                    ),
                    style: hintTips,
                    controller: _unameController,
                    // 校验用户名（不能为空）
                    validator: (v) {
                      return v.trim().isNotEmpty ? null : '手机号不能为空';
                    }
                ),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 4),
              ),
              Container(
                child: TextFormField(
                  style: hintTips,
                  controller: _pwdController,
                  decoration: InputDecoration(
                      hintText: '请输入密码',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                            pwdShow ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            pwdShow = !pwdShow;
                          });
                        },
                      )
                  ),
                  obscureText: !pwdShow,
                  //校验密码（不能为空）
                  validator: (v) {
                    return v.trim().isNotEmpty ? null : '密码不能为空';
                  },
                ),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 4),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                margin: EdgeInsets.only(top: 30),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(20))),
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      "登陆",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                  onPressed: () {
                    print("点击");
                    _onLogin();
                  },
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        InkWell(
                          child: Text("忘记密码",style: TextStyle(fontSize: AdaptiveTools.setPx(13),color: Colors.blue),),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));
                          },
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text("没有账号？",style: TextStyle(fontSize: AdaptiveTools.setPx(13)),),
                        InkWell(
                          child: Text("点击注册",style: TextStyle(fontSize: AdaptiveTools.setPx(13),color: Colors.blue),),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                          },
                        )
                      ],
                    )
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 25),
              )
            ],
          ),
        ),
      ),
    );
  }


  void _onLogin() async {
    /// 提交前，先验证各个表单字段是否合法
    if ((_formKey.currentState as FormState).validate()) {
      CommonUtil.showLoadingDialog(context);
      Oauth_2.Login_oauth2(_unameController.text, _pwdController.text, context).then((boola) {
        if (boola == 'success') {
          print("success");
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (context) => TabNavigator(),
          ),(Route<dynamic> route) => false);
        } else {
          Navigator.pop(context);
          (Connectivity().checkConnectivity()).then((onConnectivtiry){
            if (onConnectivtiry == ConnectivityResult.none) {
              FocusScope.of(context).requestFocus(FocusNode());
              MyToast.show("网络未连接");
            }else{
              MyToast.show("用户名或密码错误");
            }
          });
        }
      });
    }
  }

}
