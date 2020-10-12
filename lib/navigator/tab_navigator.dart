import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/pages/home_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/pages/welcome_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/oauth.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

class TabNavigator extends StatefulWidget {
  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  final _defaultColor = Colors.grey;
  final _activeColor = Colors.blue;
  int _currentIndex = 0;
  bool isLoadUserOk = false;
  bool isLoginOk = false;

  List<Widget> bodyWidget;

  int loadingNum = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    (Connectivity().checkConnectivity()).then((onConnectivtiry){
      if (onConnectivtiry == ConnectivityResult.none) {
        print("网络未连接");
        _loadUser();
        MyToast.show("网络未连接");
      }else{
        isLogin();
      }
    });
  }

  _updateLodingNum(int num){
    if (loadingNum != 0) {
      setState(() {
        loadingNum += num;
      });
    }else{
      setState(() {
        loadingNum = num;
      });
    }
  }

  isLogin() {
    print("获取Token");
    Shared_pre.Shared_getToken().then((token) {
      if (token == null) {
        print('没有Token');
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WelcomePage()), (route) => false);
      }else{
        Oauth_2.ResToken(context, isLogin: false);
        _loadUser();
      }
    });
  }

  _loadUser() {
    Shared_pre.Shared_getUser().then((userModel) {
      if (userModel == null) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WelcomePage()), (route) => false);
      }else{
        bodyWidget = [
          HomePage((num) => _updateLodingNum(num),key: childKey,),
          MinePage(
            userid: userModel.id,
            wLoginUserId: userModel.id,
            isTabNav: true,
          )
        ];
        setState(() {
          isLoadUserOk = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoadUserOk
          ? IndexedStack(
        index: _currentIndex,
        children: bodyWidget,
      )
          : Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 0 && loadingNum != 0) {
            childKey.currentState.ref();
            setState(() {
              loadingNum = 0;
            });
          }
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          _bottomItem('首页', Icons.home, 0),
          _bottomItem('我的', Icons.account_circle, 1),
        ],
      ),
    );
  }

  _bottomItem(String title, IconData icon, int index) {
    return BottomNavigationBarItem(
        icon: index == 1
            ? Icon(
                icon,
                color: _defaultColor,
              )
            : Stack(
                children: <Widget>[
                  Container(
                    child: Image.asset("images/home.png"),
                    height: AdaptiveTools.setRpx(46),
                  ),
                  loadingNum != 0
                      ? Container(
                          margin: EdgeInsets.only(
                              left: AdaptiveTools.setRpx(24),
                              bottom: AdaptiveTools.setRpx(3)),
                          width: AdaptiveTools.setRpx(26),
                          height: AdaptiveTools.setRpx(26),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          child: Center(
                            child: loadingNum > 99
                                ? Text(
                                    "99",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AdaptiveTools.setRpx(20)),
                                  )
                                : Text(
                                    "${loadingNum}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AdaptiveTools.setRpx(20)),
                                  ),
                          ),
                        )
                      : Container(
                          width: 0,
                          height: 0,
                        )
                ],
              ),
        activeIcon: index == 0
            ? Stack(
          children: <Widget>[
            Container(
              child: Image.asset("images/onhome.png"),
              height: AdaptiveTools.setRpx(46),
            ),
            loadingNum != 0
                ? Container(
              margin: EdgeInsets.only(
                  left: AdaptiveTools.setRpx(22),
                  bottom: AdaptiveTools.setRpx(3)),
              width: AdaptiveTools.setRpx(26),
              height: AdaptiveTools.setRpx(26),
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius:
                  BorderRadius.all(Radius.circular(50))),
              child: Center(
                child: loadingNum > 99
                    ? Text(
                  "99",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: AdaptiveTools.setRpx(20)),
                )
                    : Text(
                  "${loadingNum}",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: AdaptiveTools.setRpx(20)),
                ),
              ),
            )
                : Container(
              width: 0,
              height: 0,
            )
          ],
        )
            : Icon(
                icon,
                color: _activeColor,
              ),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 13,
              color: _currentIndex != index ? _defaultColor : _activeColor),
        ));
  }
}
