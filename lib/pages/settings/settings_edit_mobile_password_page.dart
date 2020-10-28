import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/pages/settings/settings_edit_mobile_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/common_util.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

class SettingsEditMobilePasswordPage extends StatefulWidget {
  String oldMobile;
  SettingsEditMobilePasswordPage({this.oldMobile});
  @override
  _SettingsEditMobilePasswordPageState createState() => _SettingsEditMobilePasswordPageState();
}

class _SettingsEditMobilePasswordPageState extends State<SettingsEditMobilePasswordPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool pwdShow = false; //密码是否显示明文
  TextEditingController _passwordController = new TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    _passwordController.dispose();
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
                  "验证你的密码",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
                padding: EdgeInsets.fromLTRB(20,20,20,10),
              ),
              Padding(
                child: Text(
                  "重新输入你的账号密码以继续",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                padding: EdgeInsets.fromLTRB(20, 0, 20, 5),
              ),
              Container(
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !pwdShow,
                  validator: (value){
                    return value.isNotEmpty &&value != "" ?null:"密码不能为空";
                  },
                  decoration: InputDecoration(
                    hintText: "密码",
                    suffixIcon: IconButton(
                      icon: Icon(
                          pwdShow ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          pwdShow = !pwdShow;
                        });
                      },
                    ),
                  ),
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
                              if (_formKey.currentState.validate()) {
                                _vaildPassword();
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

  _vaildPassword()async{
    String token = await Shared_pre.Shared_getToken();
    Options options = Options(headers: {'Authorization': 'Bearer $token'});
    FormData formData = FormData.fromMap({"password":_passwordController.text});
    CommonUtil.showLoadingDialog(context);
    try {
      final response = await dio.post("http://mblog.yunep.com/api/reset/valid/password", data: formData,options: options);
      if (response.statusCode == 200) {
        if (!response.data) {
          MyToast.show("密码错误");
        }
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => SettingEditPasswordPage(oldMobile:widget.oldMobile,password: _passwordController.text,)));
      } else {
        Navigator.pop(context);
        throw Exception("save info error....");
      }
    }on DioError catch(e){
      Navigator.pop(context);
      MyToast.show("密码错误");
    }
  }
}
