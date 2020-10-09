import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/pages/settings/setting_edit_mobile_code_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingEditPasswordPage extends StatefulWidget {
  String oldMobile;
  String password;
  SettingEditPasswordPage({this.oldMobile,this.password});
  @override
  _SettingEditPasswordPageState createState() => _SettingEditPasswordPageState();
}

class _SettingEditPasswordPageState extends State<SettingEditPasswordPage> {
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _mobilePassword = new TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    _mobilePassword.dispose();
    super.dispose();
  }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  "更改手机号",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
                padding: EdgeInsets.fromLTRB(20,20,20,10),
              ),
              Padding(
                child: Text(
                  "你目前的手机号是+86${widget.oldMobile} , 你想要把它更新为？",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
              ),
              Container(
                child: TextFormField(
                  controller: _mobilePassword,
                  decoration: InputDecoration(
                    hintText: "请输入你新的手机号"
                  ),
                  validator: (value){
                    RegExp regExp = new RegExp(r"1[0-9]\d{9}$");
                    print("${value}");
                    print("开始校验：${regExp.hasMatch(value)}");
                    return regExp.hasMatch(value)?null:"请输入一个正确的手机号";
                  },
                ),
                padding: EdgeInsets.symmetric(horizontal: 20),
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
                    Row(
                      children: <Widget>[
                        InkWell(
                          child: Container(
                            padding:EdgeInsets.only(left: AdaptiveTools.setRpx(40)),
                            child: Text("取消",style: TextStyle(color: Colors.blue),),
                          ),
                          onTap: (){
                            Navigator.pop(context);
                          },
                        ),
                        Container(
                          padding: EdgeInsets.only(left: AdaptiveTools.setPx(245)),
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
                                _sendCode(context);
                              }
                            },
                          ),
                        )
                      ],
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

  _sendCode(BuildContext context) {
    return showDialog(context: context,builder: (context){
      return AlertDialog(
        title: Text("验证手机"),
        titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        content: Text('我们会将验证码发送到+86${_mobilePassword.text}，可能会产生标准短信、呼叫和数据流量费用'),
        actions: <Widget>[
          FlatButton(
            child: Text('编辑'),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text('确认'),
            onPressed: (){
              print("sdsadsda"+_mobilePassword.text);
              _sendMobileCode(_mobilePassword.text);
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingEditMobileCodePage(_mobilePassword.text)));
            },
          )
        ],
      );
    });
  }

  _sendMobileCode(String mobile) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      FormData formData = FormData.fromMap({"mobile":mobile});
      final response = await dio.post(
        "http://mblog.yunep.com/api/reset/code",data: formData,options: options
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        Fluttertoast.showToast(
            msg: "发送成功",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0XF20A2F4),
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }on DioError catch(e) {
      Fluttertoast.showToast(
          msg: e.response.data["message"] == "user.account.exist"?"该用户已经绑定其他账号":e.response.data["message"],
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
