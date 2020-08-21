import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/login_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

class MyDrawer extends StatelessWidget {
  final UserModel userModel;

  const MyDrawer({Key key, this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          _buildHeader(context),
          Expanded(child: _buildMenus(context)), //构建功能菜单
        ],
      ),
    );
  }

  _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("login...${userModel.name}");
        Navigator.push(context, MaterialPageRoute(builder: (context) => MinePage()));
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border(bottom: BorderSide(width: 1, color: Color(0xfff2f2f2)))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: ClipOval(
                child: Image.network(
                  userModel.avatar,
                  width: 70,
                ),
              ),
            ),
            Text(
              userModel.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 19),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                userModel.email ?? userModel.username,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
            Row(children: <Widget>[
              Text('1',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.only(left: 2, right: 15),
                  child: Text('正在关注', style: TextStyle(color: Colors.grey))),
              Text('0',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Text('个关注者', style: TextStyle(color: Colors.grey))),
            ]),
          ],
        ),
      ),
    );
  }

  _buildMenus(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: ListView(
        children: <Widget>[
          ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('个人资料'),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MinePage()))),
          ListTile(
              leading: Icon(Icons.message),
              title: Text('关注请求'),
              onTap: () => print('关注请求')),
          ListTile(
              leading: Icon(Icons.settings),
              title: Text('隐私设置'),
              onTap: () => print('隐私设置')),
          ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('关于我们'),
              onTap: () => print('关于我们')),
          ListTile(
              leading: Icon(Icons.color_lens),
              title: Text('换肤'),
              onTap: () => print('换肤')),
          ListTile(
              leading: Icon(Icons.language),
              title: Text('语言'),
              onTap: () => print('语言')),
          ListTile(
              leading: Icon(Icons.power_settings_new),
              title: Text('登出'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return _confirmLogout(context);
                    });
              })
        ],
      ),
    );
  }

  _confirmLogout(BuildContext context) {
    return AlertDialog(
      content: Text('是否确认退出登录?'),
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
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
