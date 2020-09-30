import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/post_publish_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/CacheImage.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
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
    if (mounted) {
      setState(() {});
    }
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
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
          child: ListView.builder(
            cacheExtent: 1.0,
            controller: _scrollController,
            physics: new AlwaysScrollableScrollPhysics(),
            itemCount: ShareTwitterDataWidget
                .of(context)
                .data.length >= 100 ? 100 : ShareTwitterDataWidget
                .of(context)
                .data.length,
            itemBuilder: (context, index) => PostCard(item: ShareTwitterDataWidget
                .of(context)
                .data[index], index: index, userId: userModel.id,avatar:userModel.avatar),
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
                  Text("点击首页图标上的小红点查看推荐数据")
                ],
              ),
            ),
          ),
        ):Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      )/*LoadingContainer(
        isLoading: _loading,
        child: ,
      )*/,
      backgroundColor: Color(0xfff5f5f5),
    );
  }


  // 上拉刷新
  Future<void> _handleRefresh() async {
    setState(() {
      initAttention();
    });
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
            child: ClipRRect(
              child: CacheImage.cachedImage(avatar,height: AdaptiveTools.setRpx(100)),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        );
      },
    );
  }
}
