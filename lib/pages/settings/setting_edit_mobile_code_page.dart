import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/pages/settings/settings_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:flutter_mblog/widget/lcfarm_code_input.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingEditMobileCodePage extends StatefulWidget {
  String mobile;
  SettingEditMobileCodePage(this.mobile);
  @override
  _SettingEditMobileCodePageState createState() => _SettingEditMobileCodePageState();
}

class _SettingEditMobileCodePageState extends State<SettingEditMobileCodePage> {
  String _code;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('重置密码', style: TextStyle(color: Colors.blue)),
          iconTheme: IconThemeData(color: Colors.blue),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              child: Text(
                "验证码确认",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              padding: EdgeInsets.fromLTRB(20,30,20,15),
            ),
            Container(
              padding: EdgeInsets.only(left: 20),
              child: Text("短信验证码已发送至${widget.mobile}",style: TextStyle(fontSize: 18,color: Colors.black54),),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20,0,20,0),
              child: CodeInputTextField(
                codeLength: 4,
                autoFocus: true,
                textInputAction: TextInputAction.go,
                onSubmit: (code){
                  setState(() {
                    _code = code;
                  });
                },
                getSmsCode: (){
                  _sendCode();
                },
              ),
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
                        print(_code);
                        if (_code.length == 4) {
                          _editMobile();
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
    );
  }

  _sendCode() async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      FormData formData = FormData.fromMap({"mobile":widget.mobile});
      final response = await dio.post(
        "http://mblog.yunep.com/api/reset/code",data: formData,options: options);
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
      print(e.toString());
      Fluttertoast.showToast(
          msg: e.response.data["message"] == "user.account.exist" ?"该用户已经绑定其他账号":e.response.data["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0XF20A2F4),
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  void _editMobile()async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      FormData formData = FormData.fromMap({"mobile":widget.mobile,"code":_code});
      final response = await dio.post(
          "http://mblog.yunep.com/api/reset/mobile",data: formData,options: options
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        Shared_pre.Shared_deleteMobile();
        Shared_pre.Shared_setMobile(widget.mobile);
        Shared_pre.Shared_getUser().then((userModel){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SettingsPage(userModel)), (route) => false);
        });
      }
    }on DioError catch(e) {
      Fluttertoast.showToast(
          msg: "修改失败",
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
