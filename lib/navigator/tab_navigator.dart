import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/main.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/pages/home_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/oauth.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:flutter_mblog/widget/share_twitter_data_widget.dart';

class TabNavigator extends StatefulWidget {
  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> with RouteAware {
  final _defaultColor = Colors.grey;
  final _activeColor = Colors.blue;
  int _currentIndex = 0;
  bool isLoadUserOk = false;
  bool isLoginOk = false;

  List<Widget> bodyWidget;
  List<PostItem> items = [];
  List<PostItem> newItems = [];
  bool _loading = false;

  int loadingNum = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUser();
    isLogin();
    _getCachePostList();
  }

  @override
  void dispose() {
    MyApp.routeObserver.unsubscribe(this);
  }

  @override
  void didPush() {
    super.didPush();
    // push进入当前页面时走这里
    print('生命周期监听 didPush');
  }

  @override
  void didPushNext() {
    super.didPushNext();
    // 当前页面push到其他页面走这里
    print('生命周期监听 didPushNext');
  }

  @override
  void didPop() {
    super.didPop();
    // pop出当前页面时走这里
    print('生命周期监听 didPop');
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // 从其他页面pop回当前页面走这里
    print('生命周期监听 didPopNext');
  }

  isLogin() async {
    String token = await Shared_pre.Shared_getToken();
    if (token != null) {
      Oauth_2.ResToken(context, isLogin: false);
    }
    if (mounted) {
      setState(() {
        isLoginOk = true;
      });
    }
  }

  _loadUser() {
    Shared_pre.Shared_getUser().then((userModel) {
      bodyWidget = [
        HomePage(),
        MinePage(
          userid: userModel.id,
          wLoginUserId: userModel.id,
        ),
      ];
      if (mounted) {
        setState(() {
          isLoadUserOk = true;
        });
      }
    });
  }

  _getCachePostList() async {
    // 获取全部缓存数据
    PostModel postModel = await Shared_pre.Shared_getTwitter();
    if (postModel != null) {
      // 如果不为空
      if (items.length == 0) {
        items = postModel.content;
      }
    } else {
      // 如果为空，获取数据并加载到缓存中
      _getRandomPostList();
    }
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }
  }

  _getRandomPostList() async {
    List<PostItem> newPostItemList = [];
    PostModel randomPostModel = await PostDao.getRandomList();
    if (randomPostModel.content.length != 0) {
      setState(() {
        loadingNum += randomPostModel.content.length;
        newItems = randomPostModel.content;
      });
      PostModel oldPostModel = await Shared_pre.Shared_getTwitter();
      if (oldPostModel != null) {
        newPostItemList.addAll(randomPostModel.content);
        newPostItemList.addAll(oldPostModel.content);
        PostModel newPostModel = new PostModel(
            content: newPostItemList, totalPages: newPostItemList.length);
        await Shared_pre.Shared_setTwitter(newPostModel);
      } else {
        newPostItemList.addAll(randomPostModel.content);
        PostModel newPostModel = new PostModel(
            content: newPostItemList, totalPages: newPostItemList.length);
        await Shared_pre.Shared_setTwitter(newPostModel);
      }
      /*setState(() {
        items.insertAll(0, randomPostModel.content);
      });*/
    }
  }

  @override
  Widget build(BuildContext context) {
    print("items.length .>>> ${items.length}");
    return ShareTwitterDataWidget(
      data: items,
      child: Scaffold(
        body: isLoadUserOk && isLoginOk && _loading
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
            if (index == 0 && loadingNum == 0) {
              _getRandomPostList();
            }
            print("loadingNum == $loadingNum");
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
                      ? InkWell(
                    child: Container(
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
                    ),
                    onTap: (){
                      if (loadingNum != 0) {
                        setState(() {
                          print("获取");
                          List<PostItem> postItemList = [];
                          if (newItems.length + items.length >= 100) {
                            int start = items.length - (newItems.length - 1);
                            items.removeRange(start, items.length);
                          }
                          postItemList.addAll(newItems);
                          postItemList.addAll(items);

                          items = postItemList;
                          loadingNum = 0;
                          newItems = [];
                        });
                      }
                    },
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
