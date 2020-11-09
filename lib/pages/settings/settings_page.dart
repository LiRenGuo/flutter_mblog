import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/settings/settings_edit_mobile_password_page.dart';
import 'package:flutter_mblog/pages/settings/settings_edit_password_page.dart';
import 'package:flutter_mblog/pages/settings/settings_edit_username_page.dart';
import 'package:flutter_mblog/pages/welcome_page.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

// ignore: must_be_immutable
class SettingsPage extends StatefulWidget {
  UserModel userModel;

  SettingsPage(this.userModel);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.blue),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "${widget.userModel.name}",
                style: TextStyle(color: Colors.black),
              ),
              Text(
                "@${widget.userModel.username}",
                style: TextStyle(color: Colors.black, fontSize: 15),
              )
            ],
          ),
        ),
        body: Container(
          color: Color(0xffE7ECF0),
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                child: Text(
                  "登陆和安全",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text("用户名"),
                      subtitle: Text(
                        "@${widget.userModel.username}",
                        style: TextStyle(fontSize: 13),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsEditUserNamePage(
                                    widget.userModel.username)));
                      },
                    ),
                    Container(
                      height: 1,
                      color: Colors.black12,
                    ),
                    ListTile(
                      title: Text("手机"),
                      subtitle: Text(
                        "+86 ${widget.userModel.mobile}",
                        style: TextStyle(fontSize: 13),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SettingsEditMobilePasswordPage(
                                      oldMobile: widget.userModel.mobile,
                                    )));
                      },
                    ),
                    Container(
                      height: 1,
                      color: Colors.black12,
                    ),
                    ListTile(
                      title: Text("密码"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SettingsEditPasswordPage()));
                      },
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        "登出",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w700),
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return _confirmLogout(context);
                            });
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _deleteData(BuildContext context) {
    return AlertDialog(
      title: Text(""),
      titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      content: Text('你确定登出吗?登出将从此设备移除所有数据'),
      actions: <Widget>[
        FlatButton(
          child: Text('取消'),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text('确认'),
          onPressed: () => _logout(context),
        )
      ],
    );
  }

  _confirmLogout(BuildContext context) {
    return AlertDialog(
      title: Text("登出"),
      titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      content: Text('你确定登出吗?登出将从此设备移除所有数据'),
      actions: <Widget>[
        FlatButton(
          child: Text('取消'),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text('确认'),
          onPressed: () => _logout(context),
        )
      ],
    );
  }

  _logout(BuildContext context) {
    Shared_pre.Shared_deleteToken();
    Shared_pre.Shared_deleteResToken();
    Shared_pre.Shared_deleteUser();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
        (route) => false);
  }
}
