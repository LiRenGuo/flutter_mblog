import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
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
        print("login...");
      },
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: ClipOval(
                child: Image.network(
                  'http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLYicLia9bCyRQhpCG3ofQ4dQhouIRlvnTv3DCox8v0sj9Tk01TmD3xPZTjFLxmARgEKy27T0RSC6UA/132',
                  width: 70,
                ),
              ),
            ),
            Text(
              'Ming',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 19),
            ),
            Text(
              '333@qq.com',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  _buildMenus(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('换肤'),
            onTap: () => print('换肤')
        ),
        ListTile(
            leading: Icon(Icons.language),
            title: Text('语言'),
            onTap: () => print('语言')
        ),
        ListTile(
            leading: Icon(Icons.power_settings_new),
            title: Text('登出'),
            onTap: (){
              showDialog(
                  context: context,
                  builder: (context) {
                    return _confirmLogout(context);
                  }
              );
            }
        )
      ],
    );
  }

  _confirmLogout(BuildContext context) {

  }
}
