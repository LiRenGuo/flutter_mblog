import 'dart:io';

import 'package:cache_image/cache_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/main.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/post_publish_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:flutter_mblog/widget/loading_container.dart';
import 'package:flutter_mblog/widget/my_drawer.dart';
import 'package:flutter_mblog/widget/post_card.dart';
import 'package:flutter_mblog/widget/share_twitter_data_widget.dart';

const PAGE_SIZE = 10;
const DEFAULT_AVATAR = 'https://zzm888.oss-cn-shenzhen.aliyuncs.com/avatar-default.png';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel userModel;
  int page = 0;
  bool _loading = true;
  bool _hasMore = true;
  bool _isRequesting = false;
  ScrollController  _scrollController = ScrollController();
  FollowModel followModel;
  FollowModel followersModel;
  bool isOkAttention = false;

  // 数据队列
  List<PostItem> items = [];

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    /*MyApp.routeObserver.subscribe(this, ModalRoute.of(context));*/
    if (mounted) {
      setState(() {});
      /*_scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.decelerate);*/
    }
    print(_scrollController.positions.length);
    if (_scrollController.positions.length != 0) {
      _scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.decelerate);
    }
  }

  @override
  void initState() {
    initAttention();
    // 获取缓存数据，一进来为空时显示暂无数据
    /*_getCachePostList();*/
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    /*MyApp.routeObserver.unsubscribe(this);*/
    super.dispose();
  }



  /*@override
  void didPush() {
    print("我回来了");
    _getRandomPostList();
  }


  @override
  void didPopNext() {
    print("我Pop回来了");
    _getRandomPostList();
  }*/

  initAttention() async {
    userModel = await Shared_pre.Shared_getUser();
    followersModel = await UserDao.getFollowersList(userModel.id, context);
    followModel =  await UserDao.getFollowingList(userModel.id,context);
    if (mounted) {
      setState(() {
        isOkAttention = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("6666666666666666 ===="+ShareTwitterDataWidget
        .of(context)
        .data.length.toString());

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "btn2",
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => PostPublishPage(avatar: userModel.avatar)
          ));
        },
        child: Image.asset('images/ic_home_compose.png', fit: BoxFit.cover, scale: 3.0),
        backgroundColor: Colors.blue
      ),
      drawer: isOkAttention ? MyDrawer(userModel: userModel,followModel: followModel,followersModel: followersModel,) : MyDrawer(userModel: userModel),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Container(
          padding: EdgeInsets.all(5),
          child: FutureBuilder(
            future: _loadLoginUser(),
            builder: (context, snapshot) {
              // 请求已结束
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  // 请求失败，显示错误
                  return _userAvatar(DEFAULT_AVATAR);
                } else {
                  // 请求成功，显示数据
                  return _userAvatar(userModel.avatar);
                }
              } else {
                // 请求未结束，显示loading
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }
          ),
        ),
        title: Container(
          child: Text(
            '主页',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          margin: EdgeInsets.only(bottom: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: isOkAttention && ShareTwitterDataWidget
            .of(context)
            .data.length != 0 ? Container(
          // 渲染数据队列
          child: NotificationListener(
            child: ListView.builder(
              cacheExtent: 1.0,
              controller: _scrollController,
              itemCount: ShareTwitterDataWidget
                  .of(context)
                  .data.length,
              itemBuilder: (context, index) => _item(ShareTwitterDataWidget
                  .of(context)
                  .data[index], index),
            ),
            onNotification: notificationFunction,
          ),
        ): ShareTwitterDataWidget
            .of(context)
            .data.length == 0 ?Container(
          child: Center(
            child: InkWell(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("暂无关注用户的帖子"),
                  Text("点击首页小图标查看推荐数据")
                ],
              ),
            ),
          ),
        ):Container(
          child: Center(
            child: CircularProgressIndicator()/*InkWell(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("暂无关注用户的帖子"),
                  Text("点击看推荐的帖子")
                ],
              ),
              onTap: (){
                _getCachePostList();
              },
            )*/,
          ),
        ),
      )/*LoadingContainer(
        isLoading: _loading,
        child: ,
      )*/,
      backgroundColor: Color(0xfff5f5f5),
    );
  }

  bool isLoadingImage = true;
  bool notificationFunction(Notification notification) {
    ///通知类型
    switch (notification.runtimeType) {
      case ScrollStartNotification:
        print("开始滚动");
        ///在这里更新标识 刷新页面 不加载图片
        setState(() {
          isLoadingImage = false;
        });
        break;
      case ScrollUpdateNotification:
        print("正在滚动");
        break;
      case ScrollEndNotification:
        print("滚动停止");

        ///在这里更新标识 刷新页面 加载图片
        setState(() {
          isLoadingImage = true;
        });
        break;
      case OverscrollNotification:
        print("滚动到边界");
        break;
    }
    return true;
  }

  // 构建单个对象
  _item(PostItem item, int index) {
      return Container(
        child: PostCard(item: item, index: index, userId: userModel.id,avatar:userModel.avatar,isLoadingImage:isLoadingImage),
      );
  }

  // 上拉刷新
  Future<void> _handleRefresh() async {
    setState(() {
      /*_getCachePostList();*/
      /*_loadData();
      initAttention();*/
    });
  }

  // 加载更多数据
  _loadData({loadMore = false}) async {
    try{
      if(_isRequesting || !_hasMore) return;
      if(loadMore) page++;
      else page = 0;
      _isRequesting = true; // 正在请求中
      _loading = true;
      PostModel postModel = await PostDao.getList(page, PAGE_SIZE , context);
      _loading = false;
      if(mounted) {
        List<PostItem> resultList = [];
        if(loadMore) {
          resultList.addAll(items);
        }
        resultList.addAll(postModel.content);
        setState(() {
          items = resultList;
          _isRequesting = false;
          _hasMore = page < postModel.totalPages;
        });
      }
    } catch(e) {
      _loading = false;
      print(e);
    }
  }

  // 加载用户信息
  Future _loadLoginUser() async {
    userModel = await Shared_pre.Shared_getUser();
  }

  // 用户头像
  Widget _userAvatar(String avatar) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.white
            ),
            child: CircleAvatar(
              backgroundImage: CacheImage(avatar,duration: Duration(seconds: 2), durationExpiration: Duration(seconds: 10)),
            ),
          ),
        );
      },
    );
  }

}
