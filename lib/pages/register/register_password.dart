import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/register_user.dart';
import 'package:flutter_mblog/pages/login_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterPasswordPage extends StatefulWidget {
  RegisterUser registerUser;
  String code;
  RegisterPasswordPage(this.registerUser,this.code);
  @override
  _RegisterPasswordPageState createState() => _RegisterPasswordPageState();
}

class _RegisterPasswordPageState extends State<RegisterPasswordPage> {
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _rpasswordController = new TextEditingController();

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool pwdShow = false;
  bool rpwdShow = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('注册', style: TextStyle(color: Colors.blue)),
          iconTheme: IconThemeData(color: Colors.blue),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  "创建你的账号",
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
                    return "密码为6~16位数字和字符组合";
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
                      margin: EdgeInsets.only(top: 20),
                      child: RichText(
                        text: TextSpan(
                          text: "注册即表示你同意",
                          children: [
                            TextSpan(
                                text: "服务条款",
                                style: TextStyle(color: Colors.blue[600]),
                                recognizer: TapGestureRecognizer()..onTap =() {
                                  print("点击");
                                }
                            ),
                            TextSpan(
                              text: "和",
                            ),
                            TextSpan(
                                text: "隐私条框",
                                style: TextStyle(color: Colors.blue[600]),
                                recognizer: TapGestureRecognizer()..onTap =() {
                                  print("点击");
                                }
                            ),
                          ],
                          style: TextStyle(color: Colors.black54,fontSize: 14.0),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20))),
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            "创建用户",
                            style: TextStyle(
                                fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            RegisterUser newRegisterUser = new RegisterUser(name: widget.registerUser.name,phone: widget.registerUser.phone,agree: "yes",vcode: widget.code,password: _passwordController.text,cpassword: _rpasswordController.text);
                            _registerUser(newRegisterUser);
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

  _registerUser(RegisterUser registerUser)async{
    try {
      print(registerUser.toString());
      FormData formData = FormData.fromMap({
        "username":registerUser.phone,
        "agree":registerUser.agree,
        "vcode":registerUser.vcode,
        "name":registerUser.name,
        "password":registerUser.password,
        "cpassword":registerUser.cpassword
      });
      final response = await dio.post(
        "http://mblog.yunep.com/api/register",data: formData
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
        /*Fluttertoast.showToast(
            msg: "注册成功",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0XF20A2F4),
            textColor: Colors.white,
            fontSize: 16.0
        );
        */
      }
    }on DioError catch(e){
      print(e.toString());
      Fluttertoast.showToast(
          msg: e.response.data["result"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0XF20A2F4),
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }
}
