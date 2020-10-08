import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/pages/register/rest_password_code_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/common_util.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _phoneController = new TextEditingController();
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
                  "输入手机号",
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
    CommonUtil.showLoadingDialog(context);
    _sendCode().then((isSuccess){
      if (isSuccess) {
        Navigator.pop(context);
        Navigator.push(context,MaterialPageRoute(builder: (context) => RestPasswordPage(_phoneController.text)));
      }else{
        Navigator.pop(context);
        MyToast.show("获取验证码失败");
      }
    });
  }

  Future<bool> _sendCode() async {
    try {
      final response = await dio.post(
        "http://mblog.yunep.com/api/forget/password/code/send?username=${_phoneController.text}",
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        return true;
      }
      return false;
    }on DioError catch(e) {
      (Connectivity().checkConnectivity()).then((onConnectivtiry){
        if (onConnectivtiry == ConnectivityResult.none) {
          FocusScope.of(context).requestFocus(FocusNode());
          MyToast.show("网络未连接");
        }else{
          print("-----"+e.toString());
          MyToast.show(e.response.data["result"]);
        }
      });
      return false;
    }
  }
}
