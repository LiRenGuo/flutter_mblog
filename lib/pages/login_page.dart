import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mblog/navigator/tab_navigator.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/oauth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  GlobalKey _formKey = new GlobalKey<FormState>();

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
        title: Text('登录', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Image.asset('images/logo.png', width: 180, height: 180,),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 4),
                child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "用户名",
                      hintText: "请输入用户名",
                      prefixIcon: Icon(Icons.person),
                    ),
                    style: hintTips,
                    controller: _unameController,
                    // 校验用户名（不能为空）
                    validator: (v) {
                      return v.trim().isNotEmpty ? null : '用户名不能为空';
                    }
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 4, 30, 4),
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
              ),
              Container(
                width: 360,
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Card(
                  color: Theme.of(context).primaryColor,
                  elevation: 3,
                  child: MaterialButton(
                    onPressed: (){
                      _onLogin();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        '登录',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  void _onLogin() async {
    // 提交前，先验证各个表单字段是否合法
    if ((_formKey.currentState as FormState).validate()) {
      Oauth_2.Login_oauth2(_unameController.text, _pwdController.text, context).then((boola) {
        if (boola == 'success') {
          print("success");
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => TabNavigator()
          ));
        } else {
          MyToast.show("用户名或密码错误");
          print("error");
        }
      });
    }
  }
}
