import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/register_user.dart';
import 'package:flutter_mblog/pages/register/check_code_page.dart';
import 'package:flutter_mblog/util/Configs.dart';
import 'package:flutter_mblog/util/common_util.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/net_utils.dart';


///
/// 注册界面：步骤
/// 1、register_page 输入手机号、姓名、学号后下一步
/// 2、check_code_page 输入验证码确认手机
/// 3、register_password 输入密码确认注册
///
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterUser registerUser;
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _unionIdController = new TextEditingController();
  final GlobalKey<FormState> _formKeyRegisterPage = new GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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
          key: _formKeyRegisterPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: ScrollConfiguration(
                    child: ListView(
                      children: [
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
                            decoration: InputDecoration(hintText: "学号或者工号"),
                            controller: _unionIdController,
                            validator: (value) {
                              return value.isNotEmpty ? null : "学号不能为空";
                            },
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          margin: EdgeInsets.only(bottom: 10),
                        ),
                        Container(
                          child: TextFormField(
                            decoration: InputDecoration(hintText: "手机号"),
                            controller: _phoneController,
                            validator: (value) {
                              RegExp regExp = new RegExp(r"1[0-9]\d{9}$");
                              print("开始校验：${regExp.hasMatch(value)}");
                              return regExp.hasMatch(value) ? null : "请输入一个正确的手机号";
                            },
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          margin: EdgeInsets.only(bottom: 10),
                        ),
                        Container(
                          child: TextFormField(
                            decoration: InputDecoration(hintText: "姓名"),
                            controller: _nameController,
                            validator: (value) {
                              return value.isNotEmpty ? null : "用户名不能为空";
                            },
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          margin: EdgeInsets.only(bottom: 10),
                        ),
                    ],
                ),
                  )
              ),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            color: Colors.blue,
                            child: Center(
                              child: Text(
                                "下一步",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                            ),
                            onPressed: () {
                              if (_formKeyRegisterPage.currentState
                                  .validate()) {
                                _sendMobileCode();
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

  void _sendMobileCode() async {
    CommonUtil.showLoadingDialog(context);
    registerUser = new RegisterUser(
        name: _nameController.text, phone: _phoneController.text);
    _sendCode().then((isSuccess) {
      if (isSuccess) {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CheckCodePage(registerUser)));
      } else {
        Navigator.pop(context);
      }
    });
  }

  // ignore: missing_return
  Future<bool> _sendCode() async {
    try {
      FocusScope.of(context).requestFocus(FocusNode());
      final response = await dio.post(
        "${Auth.ipaddress}/api/register/code/send?username=${_phoneController.text}"
            "&unionId=${_unionIdController.text}&name=${_nameController.text}",
      );
      if (response.statusCode == 200) {
        return true;
      }
    } on DioError catch (e) {
      (Connectivity().checkConnectivity()).then((onConnectivtiry) {
        if (onConnectivtiry == ConnectivityResult.none) {
          FocusScope.of(context).requestFocus(FocusNode());
          MyToast.show("网络未连接");
        } else {
          print("异常 >> ${e.response.data["result"]}");
          if(e.response.data["result"] == ""){
            MyToast.show("发送验证码失败");
          }else{
            MyToast.show(e.response.data["result"]);
          }
        }
      });
      return false;
    }
  }
}
