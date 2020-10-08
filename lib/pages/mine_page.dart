import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_mblog/dao/follow_dao.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/main.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/mypost_model.dart';
import 'package:flutter_mblog/model/post_like_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/edit_mine_page.dart';
import 'package:flutter_mblog/pages/following_page.dart';
import 'package:flutter_mblog/pages/followme_page.dart';
import 'package:flutter_mblog/pages/post_publish_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/util/image_process_tools.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:flutter_mblog/widget/like_page.dart';
import 'package:flutter_mblog/widget/tweets_page.dart';

class MinePage extends StatefulWidget {
  String userid;
  String wLoginUserId;

  MinePage({this.userid, this.wLoginUserId});

  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with SingleTickerProviderStateMixin, RouteAware {
  UserModel _userModel = new UserModel();
  int totalElements;
  List<MyPostItem> _myPostModel = [];
  List<PostLikeItem> _myLikePostModel = [];
  int totalLikeElements;
  TabController tabController;
  bool isok = false;
  bool isLoadingMyPost = false;
  bool isLoadingMyLikePost = false;
  FollowModel followModel; // 正在关注的人
  FollowModel followersModel; // 关注者

  double tabHeight = 310;
  int page = 0;
  int likePage = 1;
  int _currentPage = 0;
  String loginUserId;

  bool isAttention = false;
  bool isOkAttention = false;

  ScrollController _controller = new ScrollController();
  EasyRefreshController _easyRefreshController = EasyRefreshController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MyApp.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    MyApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.
    print('返回NewView');
    _easyRefreshController.callRefresh();
  }


  @override
  void initState() {
    super.initState();
    loginUserId = widget.wLoginUserId;
    initAttention();
    _getMyPostList();
    _getLikePostList(1);
    _getUserInfo();
    tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        page++;
        likePage++;
        _getMyPostListNo(page);
        _getLikePostListNo(likePage);
      }
    });
  }

  initAttention() async {
    if (widget.userid != null && widget.userid != "") {
      followersModel = await UserDao.getFollowersList(widget.userid, context);
      followModel = await UserDao.getFollowingList(widget.userid, context);
    } else {
      UserModel userModel = await Shared_pre.Shared_getUser();
      followersModel = await UserDao.getFollowersList(userModel.id, context);
      followModel = await UserDao.getFollowingList(userModel.id, context);
    }
    UserModel userModel = await Shared_pre.Shared_getUser();
    FollowModel myFollowModel = await UserDao.getFollowingList(userModel.id, context);
    bool isAtt = false;
    if (myFollowModel != null && myFollowModel.followList.length != 0) {
      myFollowModel.followList.forEach((element) {
        if (element.id == widget.userid) {
          isAtt = true;
        }
      });
    }
    if (mounted) {
      setState(() {
        isOkAttention = true;
        isAttention = isAtt;
      });
    }
  }

  _getUserInfo() async {
    UserModel info;
    if (widget.userid != null) {
      info = await UserDao.getUserInfoByUserId(widget.userid, context);
    } else {
      info = await UserDao.getUserInfo(context);
    }
    if (info != null) {
      setState(() {
        _userModel = info;
        isok = true;
      });
    }
  }

  // 获取更多帖子
  _getMyPostListNo(int page) async {
    MyPostModel myPostModel;
    if (widget.userid != null) {
      myPostModel = await PostDao.getYourPostList(context, widget.userid, page);
    } else {
      myPostModel = await PostDao.getMyPostList(context, page);
    }
    setState(() {
      _myPostModel.addAll(myPostModel.itemList);
    });
    if (myPostModel.itemList.length == 0) {
      setState(() {
        this.page = this.page - 1;
      });
    }
  }

  _getMyPostList() async {
    MyPostModel myPostModel;
    if (widget.userid != null) {
      myPostModel = await PostDao.getYourPostList(context, widget.userid, page);
    } else {
      myPostModel = await PostDao.getMyPostList(context, page);
    }
    if (myPostModel != null) {
      setState(() {
        _myPostModel = myPostModel.itemList;
        totalElements = myPostModel.totalElements;
        isLoadingMyPost = true;
      });
    }
  }

  _getLikePostListNo(int likePostPage) async {
    PostLikeModel myPostLikeModel =
        await PostDao.getMyLikePost(widget.userid, likePostPage, context);
    if (myPostLikeModel != null) {
      setState(() {
        _myLikePostModel.addAll(myPostLikeModel.postLikeItemList);
        isLoadingMyLikePost = true;
      });
    }
    if (myPostLikeModel.postLikeItemList.length == 0) {
      setState(() {
        this.likePage = this.likePage - 1;
      });
    }
  }

  _getLikePostList(int likePostPage) async {
    PostLikeModel myPostLikeModel =
        await PostDao.getMyLikePost(widget.userid, likePostPage, context);
    if (myPostLikeModel != null) {
      setState(() {
        _myLikePostModel = myPostLikeModel.postLikeItemList;
        isLoadingMyLikePost = true;
      });
    }
  }

  Future<Null> _onRefresh() async {
    setState(() {
      page = 0;
      likePage = 0;
      _getUserInfo();
      _getMyPostList();
      _getLikePostList(1);
      initAttention();
    });
    return null;
  }

  _followYou(String userId) {
    print(userId);
    FollowDao.follow(userId, context);
    setState(() {
      isAttention = true;
    });
  }

  _unfollowYou(String userId) {
    print(userId);
    FollowDao.unfollow(userId, context);
    setState(() {
      isAttention = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pageWidget = [
      Tweets(_myPostModel, widget.userid, loginUserId, _userModel.avatar),
      LikePage(_myLikePostModel, widget.userid, loginUserId, _userModel.avatar)
    ];
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "btn1",
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PostPublishPage(avatar: _userModel.avatar)));
          },
          child: Image.asset('images/ic_home_compose.png',
              fit: BoxFit.cover, scale: 3.0),
          backgroundColor: Colors.blue),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                child: Text(
              _userModel?.name ?? "",
              style: TextStyle(color: Colors.black),
            )),
            Container(
              child: Text(
                "${totalElements ?? 0} 推文",
                style: TextStyle(
                    fontSize: AdaptiveTools.setPx(13), color: Colors.black54),
              ),
            )
          ],
        ),
      ),
      body: isok && isLoadingMyPost
          ? Container(
              child: EasyRefresh(
                controller: _easyRefreshController,
                header: MaterialHeader(),
                child: ListView(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                            child: Stack(
                              children: <Widget>[
                                Container(
                                    height: AdaptiveTools.setPx(150),
                                    width: MediaQuery.of(context).size.width,
                                    child: _userModel.banner == null
                                        ? Container(
                                      color: Colors.black54,
                                    )
                                        : ImageProcessTools.CachedNetworkProcessImage(_userModel.banner,memCacheWidth: 600,memCacheHeight: 450)/*CacheImage.cachedImage(_userModel.banner)*/
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: AdaptiveTools.setPx(125)),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: AdaptiveTools.setRpx(18),
                                            bottom: AdaptiveTools.setRpx(10)),
                                        child: ClipOval(
                                          child: ImageProcessTools.CachedNetworkProcessImage(_userModel.avatar,memCacheHeight: 250,memCacheWidth: 250),
                                        ),
                                        width: AdaptiveTools.setRpx(160),
                                        height:  AdaptiveTools.setRpx(160),
                                      ),
                                      Container(
                                        child: widget.userid == loginUserId
                                            ? RaisedButton(
                                          color: Colors.white,
                                          textColor: Colors.blue,
                                          child: Text(
                                            "编辑个人资料",
                                            style: TextStyle(
                                                fontSize:
                                                AdaptiveTools.setPx(13),
                                                fontWeight: FontWeight.w700),
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.blue)),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditMinePage()));
                                          },
                                        )
                                            : RaisedButton(
                                          color: Colors.white,
                                          textColor: Colors.blue,
                                          child: isAttention
                                              ? Text(
                                            "取消关注",
                                            style: TextStyle(
                                                fontSize:
                                                AdaptiveTools.setPx(
                                                    15),
                                                fontWeight:
                                                FontWeight.w800),
                                          )
                                              : Text(
                                            "关注",
                                            style: TextStyle(
                                                fontSize:
                                                AdaptiveTools.setPx(
                                                    15),
                                                fontWeight:
                                                FontWeight.w800),
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20),
                                              side: BorderSide(
                                                  color: Colors.blue)),
                                          onPressed: () {
                                            isAttention
                                                ? _unfollowYou(widget.userid)
                                                : _followYou(widget.userid);
                                          },
                                        ),
                                        margin: EdgeInsets.only(
                                            top: AdaptiveTools.setPx(10),
                                            right: AdaptiveTools.setPx(15)),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  _userModel.name,
                                  style: TextStyle(
                                      fontSize: AdaptiveTools.setPx(20),
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              Container(
                                child: Text(
                                  "@${_userModel.username}",
                                  style: TextStyle(
                                      fontSize: AdaptiveTools.setPx(14),
                                      color: Colors.black54),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 3),
                                child: Text(
                                  _userModel.intro == null ||
                                      _userModel.intro == ""
                                      ? "这个人很懒，什么都没有写下！！！"
                                      : _userModel.intro,
                                  style: TextStyle(
                                      fontSize: AdaptiveTools.setPx(15)),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(
                                      top: AdaptiveTools.setPx(5)),
                                  child: Row(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            height: 19,
                                            child: Image.asset("images/lng.png"),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(bottom: 2),
                                            child: Text(
                                              _userModel.address ?? "外星球",
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.black54),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            child: Image.asset("images/ic_vector_calendar.png"),
                                            height: 19,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Container(
                                            child: Text(
                                              "${TimeUtil.parse(_userModel.ctime.toString())}加入",
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.black54),
                                            ),
                                            margin: EdgeInsets.only(bottom: 2),
                                          )
                                        ],
                                      )
                                    ],
                                  )),
                              Container(
                                  margin: EdgeInsets.only(top: 6),
                                  child: Row(
                                    children: <Widget>[
                                      InkWell(
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              isOkAttention
                                                  ? followModel
                                                  .followList.length
                                                  .toString()
                                                  : "0",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 18),
                                            ),
                                            SizedBox(
                                              width: 3,
                                            ),
                                            Text("正在关注"),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FollowingPage(
                                                        userId: _userModel.id,
                                                        wLoginId: widget.wLoginUserId,
                                                        followModel:
                                                        followModel,
                                                      )));
                                        },
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      InkWell(
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              isOkAttention
                                                  ? followersModel
                                                  .followList.length
                                                  .toString()
                                                  : "0",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 18),
                                            ),
                                            SizedBox(
                                              width: 3,
                                            ),
                                            Text("个关注者")
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FollowMePage(
                                                        userId: _userModel.id,
                                                        followMeModel:
                                                        followersModel,
                                                      )));
                                        },
                                      )
                                    ],
                                  ))
                            ],
                          ),
                          alignment: Alignment.topLeft,
                        )
                      ],
                    ),
                    Container(
                      child: TabBar(
                        unselectedLabelColor: Colors.black54,
                        unselectedLabelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AdaptiveTools.setRpx(28)),
                        labelStyle: TextStyle(
                            fontSize: AdaptiveTools.setRpx(28),
                            fontWeight: FontWeight.w900),
                        labelColor: Colors.blue,
                        controller: tabController,
                        indicatorWeight: 4,
                        onTap: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        tabs: <Widget>[
                          Tab(
                            text: "推文",
                          ),
                          Tab(
                            text: "喜欢",
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: pageWidget[_currentPage],
                    )
                  ],
                ),
                onRefresh: _onRefresh,
                scrollController: _controller,
              ),
            )
          : Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
