import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/post_publish_page.dart';
import 'package:flutter_mblog/pages/search_page.dart';
import 'package:flutter_mblog/util/image_process_tools.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:flutter_mblog/widget/my_drawer.dart';
import 'package:flutter_mblog/widget/post_card.dart';

import '../main.dart';

const PAGE_SIZE = 10;
const DEFAULT_AVATAR = 'https://zzm888.oss-cn-shenzhen.aliyuncs.com/avatar-default.png';
GlobalKey<_HomePageState> childKey = GlobalKey();

class HomePage extends StatefulWidget {
  final loadingCacheData;
  final logNum;
  HomePage(this.loadingCacheData, this.logNum, {Key key}) :super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  EasyRefreshController _easyRefreshController = EasyRefreshController();
  ImageCache get imageCache => PaintingBinding.instance.imageCache;

  UserModel userModel;
  int page = 0;
  ScrollController _scrollController = ScrollController();
  FollowModel followModel;
  FollowModel followersModel;

  // 数据队列
  List<PostItem> items = [];

  bool _loading = false;
  bool isOkAttention = false;

  void ref() {
    if (items.length != 0) {
      _easyRefreshController.callRefresh();
    } else {
      _handleRefresh();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    MyApp.routeObserver.unsubscribe(this);
    _easyRefreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    (Connectivity().checkConnectivity()).then((onConnectivtiry) {
      if (onConnectivtiry == ConnectivityResult.none) {
        isOkAttention = true;
        MyToast.show("网络未连接");
      } else {
        initAttention();
      }
    });
    // 获取缓存数据，一进来为空时显示暂无数据
    _getCachePostList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // 滑动到最底部了
        print("到最底部了");
      }
    });
    super.initState();
  }

  initAttention() async {
    userModel = await Shared_pre.Shared_getUser();
    followersModel = await UserDao.getFollowersList(userModel.id, context);
    followModel = await UserDao.getFollowingList(userModel.id, context);
    if (mounted) {
      setState(() {
        isOkAttention = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MyApp.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  /*@override
  void didPopNext() {
    _getRandomPostList();
  }*/

  @override
  void didPush() {
    _getRandomPostList();
  }

  _getCachePostList() async {
    PostModel postModel = await Shared_pre.Shared_getTwitter();
    if (postModel != null) {
      /// 如果不为空
      items = postModel.content;
    } else {
      /// 如果为空，获取数据并加载到缓存中
      items = [];
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
    PostModel randomPostModel = await PostDao.getRandomList(context);
    if (randomPostModel != null && randomPostModel.content.length != 0) {
      widget.loadingCacheData(randomPostModel.content.length);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.length > 100) {
      items.removeRange(101, items.length);
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          heroTag: "btn2",
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => PostPublishPage(avatar: userModel.avatar)
            ));
          },
          child: Image.asset(
              'images/ic_home_compose.png', fit: BoxFit.cover, scale: 3.0),
      ),
      drawer: isOkAttention ? MyDrawer(userModel: userModel,
        followModel: followModel,
        followersModel: followersModel,) : MyDrawer(userModel: userModel),
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
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          margin: EdgeInsets.only(bottom: 1),
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(right: 20),
            child: InkWell(
              child: Icon(Icons.search,color: Colors.blue,),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SearchPage()));
              },
            ),
          ),
          /*
          RaisedButton(
            child: Text("测试"),
            onPressed: () {
              bool istrue =  imageCache.evict("http://photo.iksns.net/2019112716373872375bc37fcfca8460.jpg");
              print("istrue  >>  ${istrue}");
            },
          ),
          RaisedButton(
            child: Text("测试"),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_){
                return new BrowserPage(url: "https://www.baidu.com/",title: "百度",);
              }));
            },
          ),
          RaisedButton(
            child: Text("测试"),
            onPressed: () async {
               PostModel po = await Shared_pre.Shared_getTwitter();
               print("目标数：${po.content.length}");
            },
          ),
          RaisedButton(
            child: Text("测试1"),
            onPressed: () async {
              print("实际数：${items.length}");
            },
          ),
          RaisedButton(
            child: Text("测试"),
            onPressed: () async {
              await Shared_pre.Shared_setToken("1");
            },
          ),
          RaisedButton(
            child: Text("测试2"),
            onPressed: () async {
              await Shared_pre.Shared_setResToken("111");
            },
          ),
          RaisedButton(
            child: Text("测试3"),
            onPressed: () async {
              String token = await Shared_pre.Shared_getToken();
              MyToast.show(token);
            },
          ),
          RaisedButton(
            child: Text("测试4"),
            onPressed: () async {
              String token = await Shared_pre.Shared_getResToken();
              MyToast.show(token);
            },
          ),*/
        ],
      ),
      body: EasyRefresh(
        controller: _easyRefreshController,
        header: MaterialHeader(),
        onRefresh: _handleRefresh,
        child: isOkAttention && _loading && items.length != 0 ? ListView
            .builder(
          cacheExtent: 1.0,
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: items.length >= 100 ? 100 : items.length,
          itemBuilder: (context, index) {
            return PostCard(item: items[index],
                index: index,
                userId: userModel.id,
                avatar: userModel.avatar);
          },
        ) : items.length == 0 ? Container(
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
          height: MediaQuery.of(context).size.height * 0.8,
        ) : Container(
          height: MediaQuery.of(context).size.height * 0.8,
          alignment: Alignment.center,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  // 上拉刷新
  Future<void> _handleRefresh() async {
    _loading = false;
    isOkAttention = false;
    if (widget.logNum() != null && widget.logNum() != 0) {
      widget.loadingCacheData(0);
      setState(() {
        initAttention();
        _getCachePostList();
      });
    } else {
      setState(() {
        initAttention();
        _handleRefreshData();
      });
    }
  }

  _handleRefreshData() async {
    List<PostItem> newPostItemList = [];
    PostDao.getRandomList(context).then((ramdomList) {
      if (ramdomList != null && ramdomList.content.length != 0) {
        Shared_pre.Shared_getTwitter().then((oldPostModel) {
          newPostItemList.addAll(ramdomList.content);
          newPostItemList.addAll(oldPostModel.content);
          PostModel newPostModel = new PostModel(
              content: newPostItemList, totalPages: newPostItemList.length);
          Shared_pre.Shared_setTwitter(newPostModel);
          setState(() {
            items.insertAll(0, ramdomList.content);
            _loading = true;
          });
        });
      } else {
        MyToast.show("暂无更多数据");
      }
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
            child: ImageProcessTools.CachedNetworkProcessImage(
                avatar, memCacheHeight: 250, memCacheWidth: 250),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      );
    },
  );
}}
