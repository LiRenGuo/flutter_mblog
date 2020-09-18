import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/register_user.dart';
import 'package:flutter_mblog/pages/register/check_code_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterUser registerUser;

  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

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
                  decoration: InputDecoration(hintText: "手机号"),
                  controller: _phoneController,
                  validator: (value){
                    RegExp regExp = new RegExp(r"1[0-9]\d{9}$");
                    print("${value}");
                    print("开始校验：${regExp.hasMatch(value)}");
                    return regExp.hasMatch(value)?null:"请输入一个正确的手机号";
                  },
                ),
                padding: EdgeInsets.symmetric(horizontal: 25),
                margin: EdgeInsets.only(bottom: 10),
              ),
              Container(
                child: TextFormField(
                  decoration: InputDecoration(hintText: "姓名"),
                  controller: _nameController,
                  validator: (value){
                    return value.isNotEmpty ? null:"用户名不能为空";
                  },
                ),
                padding: EdgeInsets.symmetric(horizontal: 25),
                margin: EdgeInsets.only(bottom: 10),
              ),
              Spacer(),
              Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 1,
                      color: Colors.black38,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: AdaptiveTools.setPx(280)),
                      margin: EdgeInsets.only(right: 10),
                      alignment: Alignment.bottomRight,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20))),
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            "下一步",
                            style: TextStyle(
                                fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _sendMobileCode();
                          }
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _sendMobileCode() async {
    registerUser = new RegisterUser(name: _nameController.text,phone: _phoneController.text);
    _sendCode().then((isSuccess){
      if (isSuccess) {
        Navigator.push(context,MaterialPageRoute(builder: (context) => CheckCodePage(registerUser)));
      }
    }); // TODO 发送验证码
  }

  Future<bool> _sendCode() async {
    try {
      print(_phoneController.text);
      final response = await dio.post(
        "http://mblog.yunep.com/api/register/code/send?username=${_phoneController.text}",
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        return true;
      }
      return false;
    }on DioError catch(e) {
      Fluttertoast.showToast(
          msg: e.response.data["result"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0XF20A2F4),
          textColor: Colors.white,
          fontSize: 16.0
      );
      return false;
    }
  }
}
