import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/about_us_page.dart';
import 'package:flutter_mblog/pages/following_page.dart';
import 'package:flutter_mblog/pages/followme_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/pages/settings/settings_page.dart';
import 'package:flutter_mblog/util/check_update_tools.dart';
import 'package:flutter_mblog/util/image_process_tools.dart';

class MyDrawer extends StatelessWidget {
  final UserModel userModel;
  final FollowModel followModel;
  final FollowModel followersModel;

  const MyDrawer({Key key, this.userModel,this.followModel,this.followersModel}) : super(key: key);

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
        Navigator.push(context, MaterialPageRoute(builder: (context) => MinePage(userid: userModel.id,wLoginUserId: userModel.id,)));
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20,40,20,20),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(width: 1, color: Color(0xfff2f2f2)))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Container(
                child: ClipOval(
                  child: ImageProcessTools.CachedNetworkProcessImage(userModel.avatar,memCacheWidth: 400,memCacheHeight: 400) /*CacheImage.cachedImage(userModel.avatar,height: AdaptiveTools.setRpx(100)),*/
                ),
                height:100,
                width: 100,
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
                userModel.email == "" ? "@${userModel.username}" : userModel.email ?? userModel.username,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
            Row(children: <Widget>[
              Text(
                  followModel != null ?followModel.followList.length.toString(): "0",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              InkWell(
                child: Padding(
                    padding: EdgeInsets.only(left: 2, right: 15),
                    child: Text('正在关注', style: TextStyle(color: Colors.grey))),
                    onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FollowingPage(userId: userModel.id,wLoginId: userModel.id,followModel: followModel,)));
                    },
              ),
              Text(followersModel != null ?followersModel.followList.length.toString(): "0",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              InkWell(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Text('个关注者', style: TextStyle(color: Colors.grey))),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FollowMePage(userId: userModel.id,followMeModel: followersModel,)));
                    },
              ),
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
        padding: EdgeInsets.all(0),
          shrinkWrap:true,
        children: <Widget>[
          ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('个人资料'),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MinePage(userid: userModel.id,wLoginUserId: userModel.id,)))),
          ListTile(
              leading: Icon(Icons.settings),
              title: Text('隐私设置'),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => SettingsPage(userModel)))),
          ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('关于我们'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AboutUsPage()))),
        ],
      ),
    );
  }
}
