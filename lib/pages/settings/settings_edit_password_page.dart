import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/util/common_util.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

class SettingsEditPasswordPage extends StatefulWidget {
  @override
  _SettingsEditPasswordPageState createState() => _SettingsEditPasswordPageState();
}

class _SettingsEditPasswordPageState extends State<SettingsEditPasswordPage> {
  TextEditingController oldPassword = new TextEditingController();
  TextEditingController newPassword = new TextEditingController();
  TextEditingController rnewPassword = new TextEditingController();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('修改手机号', style: TextStyle(color: Colors.black)),
          iconTheme: IconThemeData(color: Colors.blue),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(9, 5, 10, 0),
                      child: Text(
                        "当前密码",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w100,
                            color: Colors.black87),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                      child: TextFormField(
                        obscureText: true,
                        controller: oldPassword,
                        style: TextStyle(
                            fontSize: 16.0, color: Colors.black),
                        decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.blue)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black26))),
                      ),
                    )
                  ],
                ),
                Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(9, 5, 10, 0),
                      child: Text(
                        "新密码",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w100,
                            color: Colors.black87),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                      child: TextFormField(
                        controller: newPassword,
                        obscureText: true,
                        validator: (value){
                          RegExp mobile = new RegExp(r"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,16}$");
                          if (mobile.hasMatch(value)) {
                            return null;
                          }
                          return "密码至少由6个字符组成，必须包含数字、字母，区分大小写";
                        },
                        style: TextStyle(
                            fontSize: 16.0, color: Colors.black),
                        decoration: InputDecoration(
                            hintText: "密码至少由6个字符组成，必须包含数字、字母，区分大小写",
                            hintStyle: TextStyle(fontSize: 16),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.blue)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black26))),
                      ),
                    )
                  ],
                ),
                Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(9, 5, 10, 0),
                      child: Text(
                        "确认密码",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w100,
                            color: Colors.black87),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                      child: TextFormField(
                        controller: rnewPassword,
                        obscureText: true,
                        validator: (value){
                          return newPassword.text == value ?null:"两次密码不一致";
                        },
                        style: TextStyle(
                            fontSize: 16.0, color: Colors.black),
                        decoration: InputDecoration(
                            hintText: "密码至少由6个字符组成，必须包含数字、字母，区分大小写",
                            hintStyle: TextStyle(fontSize: 16),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.blue)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.black26))),
                      ),
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      margin: EdgeInsets.only(top: 15),
                      width: double.infinity,
                      child: RaisedButton(
                        child: Text("更新密码",style: TextStyle(color: Colors.black),),
                        onPressed: (){
                          if (_formKey.currentState.validate()) {
                            onRestPassword();
                          }
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  void onRestPassword() async{
    String token = await Shared_pre.Shared_getToken();
    Options options = Options(headers: {'Authorization': 'Bearer $token'});
    FormData formData = FormData.fromMap({"password":newPassword.text,"cpassword":rnewPassword.text,"oldpassword":oldPassword.text});
    CommonUtil.showLoadingDialog(context);
    try {
      final response = await dio.post("http://mblog.yunep.com/api/reset/password", data: formData,options: options);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        throw Exception("save info error....");
      }
    }on DioError catch(e){
      Navigator.pop(context);
      MyToast.show("修改密码错误");
    }
  }
}
