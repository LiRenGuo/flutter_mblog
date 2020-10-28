
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../login_page.dart';

class RestPasswordEndPage extends StatefulWidget {
  String phone;
  String code;
  RestPasswordEndPage(this.phone,this.code);
  @override
  _RestPasswordEndPageState createState() => _RestPasswordEndPageState();
}

class _RestPasswordEndPageState extends State<RestPasswordEndPage> {
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _rpasswordController = new TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool pwdShow = false;
  bool rpwdShow = false;

  @override
  void dispose() {
    // TODO: implement dispose
    _passwordController.dispose();
    _rpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('重置密码', style: TextStyle(color: Colors.blue)),
          iconTheme: IconThemeData(color: Colors.blue),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  "输入你的新密码",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
                padding: EdgeInsets.all(20),
              ),
              Container(
                child: TextFormField(
                  controller: _passwordController,
                  validator: (value){
                    RegExp mobile = new RegExp(r"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,16}$");
                    if (mobile.hasMatch(value)) {
                      return null;
                    }
                    return "密码至少由6个字符组成，必须包含数字、字母，区分大小写";
                  },
                  obscureText: !pwdShow,
                  decoration: InputDecoration(hintText: "密码",suffixIcon: IconButton(
                    icon: Icon(
                        pwdShow ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        pwdShow = !pwdShow;
                      });
                    },
                  )),
                ),
                padding: EdgeInsets.symmetric(horizontal: 25),
                margin: EdgeInsets.only(bottom: 10),
              ),
              Container(
                child: TextFormField(
                  validator: (value){
                    return value == _passwordController.text ? null: "两次密码输入不一致";
                  },
                  controller: _rpasswordController,
                  obscureText: !rpwdShow,
                  decoration: InputDecoration(hintText: "确认密码",suffixIcon: IconButton(
                    icon: Icon(
                        rpwdShow ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        rpwdShow = !rpwdShow;
                      });
                    },
                  )),
                ),
                padding: EdgeInsets.symmetric(horizontal: 25),
                margin: EdgeInsets.only(bottom: 10),
              ),
              Container(
                child:  Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20))),
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            "重置密码",
                            style: TextStyle(
                                fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _registerUser(widget.phone,widget.code);
                          }
                        },
                      ),
                    )
                  ],
                ),
                margin: EdgeInsets.only(top: 20),
              )
            ],
          ),
        ),
      ),
    );
  }

  _registerUser(String phone,String code)async{
    try {
      FormData formData = FormData.fromMap({
        "username":phone,
        "vcode":code,
        "password":_passwordController.text,
        "cpassword":_rpasswordController.text
      });
      final response = await dio.post(
          "http://mblog.yunep.com/api/forget/password",data: formData
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    }on DioError catch(e){
      print(e.toString());
      MyToast.show(e.response.data["result"]);
    }
  }
}
