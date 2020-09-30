import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/follow_dao.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/mypost_model.dart';
import 'package:flutter_mblog/model/post_like_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/edit_mine_page.dart';
import 'package:flutter_mblog/pages/following_page.dart';
import 'package:flutter_mblog/pages/followme_page.dart';
import 'package:flutter_mblog/pages/home_detail_page.dart';
import 'package:flutter_mblog/pages/post_publish_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/CacheImage.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:flutter_mblog/widget/fade_route.dart';
import 'package:flutter_mblog/widget/image_all_screen_look.dart';
import 'package:flutter_mblog/widget/tweets_page.dart';
import 'package:like_button/like_button.dart';
import 'package:optimized_cached_image/widgets.dart';

import '../dao/user_dao.dart';

class MinePage extends StatefulWidget {
  String userid;
  String wLoginUserId;

  MinePage({this.userid, this.wLoginUserId});

  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with SingleTickerProviderStateMixin {
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

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    var bool = ModalRoute.of(context).isCurrent;
    if(bool){
      _getUserInfo();
    }
  }

  @override
  void initState() {
    super.initState();
    initAttention();
    _getMyPostList();
    _getLikePostList(1);
    tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    loginUserId = widget.wLoginUserId;
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
    _getUserInfo();
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
    print("myLikePostModel == " + myPostLikeModel.toString());
    if (myPostLikeModel != null) {
      print("myLikePostModel == " + myPostLikeModel.toString());
      setState(() {
        _myLikePostModel = myPostLikeModel.postLikeItemList;
        isLoadingMyLikePost = true;
      });
    }
  }

  Future<Null> _onRefresh() async {
    print("下拉刷新");
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
      Like(_myLikePostModel, widget.userid, loginUserId, _userModel.avatar)
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
              child: RefreshIndicator(
                child: ListView(
                  physics: new AlwaysScrollableScrollPhysics(),
                  controller: _controller,
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
                                  : CacheImage.cachedImage(_userModel.banner)
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
                                      child: Image(
                                        fit: BoxFit.cover,
                                        image: OptimizedCacheImageProvider(_userModel.avatar),
                                      ),
                                    ),
                                    width: AdaptiveTools.setRpx(160),
                                    height:  AdaptiveTools.setRpx(160),
                                  )
                                  /*Container(
                                    child: CircleAvatar(
                                        maxRadius: AdaptiveTools.setPx(40),
                                        backgroundImage:
                                            NetworkImage(_userModel.avatar)),
                                    margin: EdgeInsets.only(
                                        left: AdaptiveTools.setPx(18),
                                        bottom: AdaptiveTools.setPx(10)),
                                  )*/,
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
                                            child:
                                                Image.asset("images/lng.png"),
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
                                            child: Image.asset(
                                                "images/ic_vector_calendar.png"),
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

class TweetsOrReply extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// ignore: must_be_immutable
class Like extends StatefulWidget {
  List<PostLikeItem> _item;
  String userId;
  String loginUserId;
  String avatar;

  Like(this._item, this.userId, this.loginUserId, this.avatar);

  @override
  _LikeState createState() => _LikeState();
}

class _LikeState extends State<Like> {
  /*void _deletePost(String id, BuildContext context) async {
    print("删除");
    PostDao.deletePost(id, context).then((value) {
      if (value == "success") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MinePage(
                      userid: widget.userId,
                    )));
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget._item.map((e) {
        return body(
            widget.userId, widget.loginUserId, e, widget.avatar, context);
      }).toList(),
    );
  }

  Future<bool> onLike(bool isLiked, PostLikeItem postItem) {
    final Completer<bool> completer = new Completer<bool>();
    Timer(const Duration(milliseconds: 200), () {
      if (postItem.islike) {
        print("dislike...");
        PostDao.dislike(postItem.id);
      } else {
        print("like...${postItem.id}");
        PostDao.like(postItem.id);
      }
      postItem.likeCount =
          postItem.islike ? postItem.likeCount + 1 : postItem.likeCount - 1;
      postItem.islike = !postItem.islike;
      completer.complete(postItem.islike);
    });
    return completer.future;
  }

  _buildLikeButton(PostLikeItem postItem) {
    return LikeButton(
      size: 22,
      onTap: (bool isLiked) {
        return onLike(isLiked, postItem);
      },
      likeBuilder: (bool isLiked) {
        return Image.asset(postItem.islike
            ? 'images/ic_home_liked.webp'
            : 'images/ic_home_like.webp');
      },
      isLiked: postItem.islike,
      likeCount: postItem.likeCount,
      countBuilder: (int count, bool isLiked, String text) {
        final ColorSwatch<int> color =
            isLiked ? Colors.pinkAccent : Colors.grey;
        Widget result;
        if (count == 0) {
          result = Text(
            '赞',
            style: TextStyle(color: color, fontSize: AdaptiveTools.setRpx(10)),
          );
        } else
          result = Text(
            count >= 1000 ? (count / 1000.0).toStringAsFixed(1) + 'k' : text,
            style: TextStyle(color: color),
          );

        return result;
      },
      likeCountAnimationType: postItem.likeCount < 1000
          ? LikeCountAnimationType.part
          : LikeCountAnimationType.none,
    );
  }

  Widget body(String userId, String loginUserId, PostLikeItem _item,
      String avatar, BuildContext context) {
    return Padding(
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: InkWell(
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: FractionalOffset.topLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: AdaptiveTools.setPx(7)),
                          child: ClipOval(
                            child: Image(
                              fit: BoxFit.cover,
                              image: OptimizedCacheImageProvider(_item.userDto.avatar),
                            ),
                          ),
                          width: AdaptiveTools.setRpx(80),
                          height:  AdaptiveTools.setRpx(80),
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MinePage(
                                  userid: _item.userDto.id,
                                  wLoginUserId: widget.loginUserId,
                                )));
                  },
                ),
                flex: 1,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      child: Row(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  _item.userDto.name,
                                  style: TextStyle(
                                    letterSpacing: 2,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Container(
                                child: Text("@${_item.userDto.username}"),
                              ),
                            ],
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MinePage(
                                      userid: _item.userDto.id,
                                      wLoginUserId: widget.loginUserId,
                                    )));
                      },
                    ),
                    InkWell(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: AdaptiveTools.setPx(3)),
                        child: Text(_item.content),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeDetailPage(
                                      null,
                                      postId: _item.id,
                                    )));
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8, bottom: 5),
                      child: image(_item.photos, context),
                    ),
                    if (_item.postId != null)
                      _buildRetweet(_item.rPostLikeItem),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                Image.asset("images/ic_home_comment.webp"),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("${_item.commentCount.toString()}")
                              ],
                            ),
                            height: AdaptiveTools.setPx(20),
                          ),
                          Container(
                            child: _buildLikeButton(_item),
                            height: AdaptiveTools.setPx(20),
                          ),
                          Container(
                            child: Image.asset(
                              "images/retweet_stroke.png",
                              color: Colors.black54,
                            ),
                            height: AdaptiveTools.setPx(17),
                          ),
                          InkWell(
                            child: Container(
                              child: Image.asset("images/ic_home_forward.png"),
                              height: AdaptiveTools.setPx(20),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PostPublishPage(
                                            avatar: avatar,
                                            postId: _item.id,
                                          )));
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                flex: 6,
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 1,
            color: Colors.black12,
          )
        ],
      ),
      padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
    );
  }

  Widget _buildRetweet(PostLikeItem postItem) {
    Widget retweetWidget;
    postItem != null && postItem.id != null
        ? retweetWidget = InkWell(
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 3, 3, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: ClipOval(
                            child: Image(
                              fit: BoxFit.cover,
                              image: OptimizedCacheImageProvider(postItem.userDto.name),
                            ),
                          ),
                          width: AdaptiveTools.setRpx(50),
                          height:  AdaptiveTools.setRpx(50),
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 8, 0, 10),
                              child: Text("${postItem.userDto.name}"),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(5, 7, 10, 10),
                              child: Text(
                                "@${postItem.userDto.username}",
                                style: TextStyle(color: Colors.black38),
                              ),
                            )
                          ],
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 6, 10, 10),
                          child: Text(
                            "${TimeUtil.parse(postItem.ctime.toString())}",
                            style:
                                TextStyle(fontSize: 13, color: Colors.black38),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 3, 3),
                    child: Text("${postItem.content}"),
                  ),
                  postItem.photos != null && postItem.photos.length != 0
                      ? _buildRetweetImage(postItem.photos)
                      : Container()
                ],
              ),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HomeDetailPage(
                        null,
                        postId: postItem.id,
                      )));
            },
          )
        : retweetWidget = Container(
            width: 0,
            height: 0,
          );
    return retweetWidget;
  }

  _buildRetweetImage(List<String> photosList) {
    Widget widgets;
    switch (photosList.length) {
      case 1:
        widgets = Container(
            height: 150,
            margin: EdgeInsets.only(top: 5),
            width: double.infinity,
            child: ClipRRect(
              child: CacheImage.cachedImage(photosList[0]),
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10)),
            ));
        break;
      case 2:
        widgets = Container(
          height: 150,
          margin: EdgeInsets.only(top: 5),
          width: double.infinity,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: ClipRRect(
                    child: CacheImage.cachedImage(photosList[0]),
                    borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(10)),
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Container(
                  child: ClipRRect(
                    child: CacheImage.cachedImage(photosList[1]),
                    borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case 3:
        widgets = Container(
          height: 150,
          margin: EdgeInsets.only(top: 5),
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: ClipRRect(
                          child: CacheImage.cachedImage(photosList[0]),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: ClipRRect(
                                child: CacheImage.cachedImage(photosList[1]),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: ClipRRect(
                                child: CacheImage.cachedImage(photosList[2]),
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      case 4:
        widgets = Container(
          height: 150,
          margin: EdgeInsets.only(top: 5),
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: ClipRRect(
                          child: CacheImage.cachedImage(photosList[0]),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        child: ClipRRect(
                          child: CacheImage.cachedImage(photosList[1]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: ClipRRect(
                          child: CacheImage.cachedImage(photosList[2]),
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        child: ClipRRect(
                          child: CacheImage.cachedImage(photosList[3]),
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
        break;
    }
    return widgets;
  }
  _showImage(BuildContext context, List<String> images, int index) {
    Navigator.of(context).push(FadeRoute(
        page: ImageAllScreenLook(
      imgDataArr: images,
      index: index,
    )));
  }

  Widget image(List<String> images, BuildContext context) {
    Widget imageWidget;
    switch (images.length) {
      case 1:
        imageWidget = GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            height: AdaptiveTools.setPx(165),
            width: double.infinity,
            margin: EdgeInsets.only(top: 3),
            child: ClipRRect(
              child: CacheImage.cachedImage(images[0]),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onTap: () => _showImage(context,images, 0),
        );
        break;
      case 2:
        imageWidget = Container(
          decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8))),
          height: AdaptiveTools.setPx(165),
          width: double.infinity,
          margin: EdgeInsets.only(top: 3),
          child: Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  child: Container(
                    height: double.infinity,
                    child: ClipRRect(
                      child: CacheImage.cachedImage(images[0]),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                    ),
                  ),
                  onTap: () => _showImage(context,images, 0),
                ),
              ),
              SizedBox(
                width: 3,
              ),
              Expanded(
                child: GestureDetector(
                  child: Container(
                    height: double.infinity,
                    child: ClipRRect(
                      child: CacheImage.cachedImage(images[1]),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8)),
                    ),
                  ),
                  onTap: () => _showImage(context,images, 1),
                ),
              )
            ],
          ),
        );
        break;
      case 3:
        imageWidget = Container(
          height: AdaptiveTools.setPx(165),
          width: double.infinity,
          margin: EdgeInsets.only(top: 3),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          child: ClipRRect(
                            child: CacheImage.cachedImage(images[0]),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8)),
                          ),
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        onTap: () => _showImage(context,images, 0),
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: CacheImage.cachedImage(images[1]),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context,images, 1),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: CacheImage.cachedImage(images[2]),
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context,images, 2),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      case 4:
        imageWidget = Container(
          height: AdaptiveTools.setPx(165),
          width: double.infinity,
          margin: EdgeInsets.only(top: 3),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: CacheImage.cachedImage(images[0]),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context,images, 0),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: CacheImage.cachedImage(images[1]),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context,images, 1),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: CacheImage.cachedImage(images[2]),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context,images, 2),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: CacheImage.cachedImage(images[3]),
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context,images, 3),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      default:
        imageWidget = Container(
          height: 0,
          width: 0,
        );
        break;
    }
    return imageWidget;
  }

}
