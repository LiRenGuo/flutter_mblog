import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/register_user.dart';
import 'package:flutter_mblog/pages/register/register_password.dart';
import 'package:flutter_mblog/util/Configs.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:flutter_mblog/widget/lcfarm_code_input.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CheckCodePage extends StatefulWidget {
  RegisterUser registerUser;
  CheckCodePage(this.registerUser);
  @override
  _CheckCodePageState createState() => _CheckCodePageState();
}

class _CheckCodePageState extends State<CheckCodePage> {
  String _code;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('注册', style: TextStyle(color: Colors.blue)),
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
              child: Text("短信验证码已发送至${widget.registerUser.phone}",style: TextStyle(fontSize: 18,color: Colors.black54),),
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
                 Row(
                   children: [
                     Spacer(),
                     Container(
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
                             Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPasswordPage(widget.registerUser,_code)));
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
    );
  }

  _sendCode() async {
    try {
      final response = await dio.post(
        "${Auth.ipaddress}/api/register/code/send?username=${widget.registerUser.phone}",
    );
      if (response.statusCode == 200) {
        MyToast.show("发送成功");
      }
    }on DioError catch(e) {
      MyToast.show(e.response.data["result"]);
    }
  }
}
