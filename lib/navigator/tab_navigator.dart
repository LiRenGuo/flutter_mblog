import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/home_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/pages/my_page.dart';
import 'package:flutter_mblog/util/shared_pre.dart';


class TabNavigator extends StatefulWidget {
  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  final _defaultColor = Colors.grey;
  final _activeColor = Colors.blue;
  int _currentIndex = 0;
  final PageController _controller = PageController(initialPage: 0);
  UserModel userModel;
  bool isLoadUserOk = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUser();
  }
  _loadUser()async{
    userModel = await Shared_pre.Shared_getUser();
   if (mounted ) {
     setState(() {
       isLoadUserOk = true;
     });
   }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoadUserOk ? PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          HomePage(),
          MinePage(userid: userModel.id,wLoginUserId: userModel.id,),
        ],
      ):Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _controller.jumpToPage(index);
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
      icon: Icon(icon, color: _defaultColor),
      activeIcon: Icon(icon, color: _activeColor),
      title: Text(
        title,
        style: TextStyle(color: _currentIndex != index ? _defaultColor : _activeColor),
      )
    );
  }
}
