import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/model/mypost_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/edit_mine_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/widget/fade_route.dart';
import 'package:flutter_mblog/widget/image_all_screen_look.dart';
import 'package:like_button/like_button.dart';

import '../dao/user_dao.dart';

class MinePage extends StatefulWidget {
  String userid;
  String loginUserId;

  MinePage({this.userid,this.loginUserId});

  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with SingleTickerProviderStateMixin {
  UserModel _userModel = new UserModel();
  int totalElements;
  List<MyPostItem> _myPostModel = [];
  TabController tabController;
  bool isok = false;
  bool isLoadingMyPost = false;

  double tabHeight = 310;
  int page = 0;

  int _currentPage = 0;

  ScrollController _controller = new ScrollController();

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _getMyPostList();
    tabController = TabController(vsync: this, length: 4, initialIndex: 0);
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        page++;
        _getMyPostListNo(page);
      }
    });
  }

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
  }

  _getUserInfo() async {
    UserModel info;
    if (widget.userid != null) {
      info = await UserDao.getUserInfoByUserId(widget.userid, context);
    } else {
      info = await UserDao.getUserInfo(context);
    }
    setState(() {
      _userModel = info;
      isok = true;
    });
  }

  _getMyPostList() async {
    MyPostModel myPostModel;
    if (widget.userid != null) {
      myPostModel = await PostDao.getYourPostList(context, widget.userid, page);
    } else {
      myPostModel = await PostDao.getMyPostList(context, page);
    }

    setState(() {
      _myPostModel = myPostModel.itemList;
      totalElements = myPostModel.totalElements;
      isLoadingMyPost = true;
    });
  }

  Future<Null> _onRefresh() async {
    print("下拉刷新");
    setState(() {
      _getUserInfo();
      _getMyPostList();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    print(_userModel.id);
    if (isok) {
      setState(() {
        int i = 0;
        _myPostModel.forEach((element) {
          if (element.photos.length == 0) {
            i++;
          }
        });
        print("重新加载 $i");
        tabHeight = AdaptiveTools.setPx(275.0) * _myPostModel.length;
        tabHeight = tabHeight - (AdaptiveTools.setPx(160) * i);
      });
    }
    List<Widget> pageWidget = [
      Tweets(_myPostModel),
      TweetsOrReply(),
      Media(),
      Like()
    ];
    ;
    return Scaffold(
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
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            )
          ],
        ),
      ),
      body: isok && isLoadingMyPost
          ? Container(
              child: RefreshIndicator(
                child: ListView(
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
                              child: Image.network(
                                _userModel.banner,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: AdaptiveTools.setPx(125)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: CircleAvatar(
                                        maxRadius: AdaptiveTools.setPx(40),
                                        backgroundImage:
                                            NetworkImage(_userModel.avatar)),
                                    margin: EdgeInsets.only(
                                        left: AdaptiveTools.setPx(18),
                                        bottom: AdaptiveTools.setPx(10)),
                                  ),
                                  Container(
                                    child: widget.userid == widget.loginUserId ?RaisedButton(
                                      color: Colors.white,
                                      textColor: Colors.blue,
                                      child: Text(
                                        "编辑个人资料",
                                        style: TextStyle(
                                            fontSize: AdaptiveTools.setPx(15),
                                            fontWeight: FontWeight.w800),
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(20),
                                          side: BorderSide(color: Colors.blue)),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditMinePage()));
                                      },
                                    ) :RaisedButton(
                                      color: Colors.white,
                                      textColor: Colors.blue,
                                      child: Text(
                                        "关注",
                                        style: TextStyle(
                                            fontSize: AdaptiveTools.setPx(15),
                                            fontWeight: FontWeight.w800),
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(20),
                                          side: BorderSide(color: Colors.blue)),
                                      onPressed: () {
                                        print("关注");
                                      },
                                    ),
                                    margin: EdgeInsets.only(
                                        bottom: AdaptiveTools.setPx(2),
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
                                      letterSpacing: 2,
                                      fontSize: AdaptiveTools.setPx(22),
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              Container(
                                child: Text(
                                  "@${_userModel.username}",
                                  style: TextStyle(
                                      fontSize: AdaptiveTools.setPx(15),
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
                                      fontSize: AdaptiveTools.setPx(16)),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(
                                      top: AdaptiveTools.setPx(5)),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        child: Image.asset(
                                            "images/ic_vector_calendar.png"),
                                        height: AdaptiveTools.setPx(17),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        "${formatDate(DateTime.fromMillisecondsSinceEpoch(_userModel.ctime), [
                                          yyyy,
                                          "年",
                                          mm,
                                          "月"
                                        ])} 加入",
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.black54),
                                      )
                                    ],
                                  )),
                              Container(
                                  margin: EdgeInsets.only(top: 6),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        _userModel.following.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18),
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text("正在关注"),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Text(
                                        _userModel.followers.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18),
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text("个关注者")
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
                            fontSize: AdaptiveTools.setPx(12)),
                        labelStyle: TextStyle(
                            fontSize: AdaptiveTools.setPx(12),
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
                            text: "推文合回复",
                          ),
                          Tab(
                            text: "媒体",
                          ),
                          Tab(
                            text: "喜欢",
                          ),
                        ],
                      ),
                    ),
                    pageWidget[_currentPage]
                    /*Flexible(
                             child: TabBarView(
                               controller: tabController,
                               children: [
                                 Tweets(_myPostModel),
                                 TweetsOrReply(),
                                 Media(),
                                 Like()
                               ],
                             ),
                           ),*/
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

class Tweets extends StatelessWidget {
  List<MyPostItem> _item;

  Tweets(this._item);

  @override
  Widget build(BuildContext context) {
    int i = 0;
    return Column(
      children: _item.map((e) {
        return body(e, context);
      }).toList(),
    );
  }

  Future<bool> onLike(bool isLiked, MyPostItem postItem) {
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

  _buildLikeButton(MyPostItem postItem) {
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
            style: TextStyle(color: color),
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

  Widget body(MyPostItem _item, BuildContext context) {
    return Padding(
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: FractionalOffset.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: AdaptiveTools.setPx(7)),
                        alignment: Alignment.topLeft,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(_item.user.avatar),
                        ),
                      ),
                    )
                  ],
                ),
                flex: 1,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: Text(
                                _item.user.name,
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
                              child: Text("@${_item.user.username}"),
                            ),
                            Container(
                              child: Text(
                                  "  ·  ${TimeUtil.parse(_item.ctime.toString())}"),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black54,
                            size: AdaptiveTools.setPx(19),
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: AdaptiveTools.setPx(3)),
                      child: Text(_item.content),
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                      child: image(_item.photos, context),
                    ),
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
                          Container(
                            child: Image.asset("images/ic_home_forward.png"),
                            height: AdaptiveTools.setPx(20),
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
        imageWidget = InkWell(
          child: Container(
            height: AdaptiveTools.setPx(165),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(images[0]), fit: BoxFit.cover),
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.all(Radius.circular(18))),
          ),
          onTap: () {
            _showImage(context, images, 0);
          },
        );
        break;
      case 2:
        imageWidget = Container(
          height: AdaptiveTools.setPx(165),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(18))),
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(images[0]), fit: BoxFit.cover),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            bottomLeft: Radius.circular(18))),
                  ),
                  onTap: () {
                    _showImage(context, images, 0);
                  },
                ),
              ),
              SizedBox(
                width: 3,
              ),
              Expanded(
                child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(images[1]), fit: BoxFit.cover),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(18),
                            bottomRight: Radius.circular(18))),
                  ),
                  onTap: () {
                    _showImage(context, images, 1);
                  },
                ),
              )
            ],
          ),
        );
        break;
      case 3:
        imageWidget = Container(
          height: AdaptiveTools.setPx(165),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(18))),
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(images[0]), fit: BoxFit.cover),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            bottomLeft: Radius.circular(18))),
                  ),
                  onTap: () {
                    _showImage(context, images, 0);
                  },
                ),
              ),
              SizedBox(
                width: 3,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[1]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 1);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[2]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 2);
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
        break;
      case 4:
        imageWidget = Container(
          height: AdaptiveTools.setPx(165),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(18))),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[0]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                              )),
                        ),
                        onTap: () {
                          _showImage(context, images, 0);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[1]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 1);
                        },
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
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[2]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 2);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[3]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 3);
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
        break;
      case 5:
        imageWidget = Container(
          height: AdaptiveTools.setPx(165),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(18))),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[0]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                              )),
                        ),
                        onTap: () {
                          _showImage(context, images, 0);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[3]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 3);
                        },
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
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[2]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 2);
                        },
                      ),
                    ),
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
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[1]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 1);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[4]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 4);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      case 6:
        imageWidget = Container(
          height: AdaptiveTools.setPx(165),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(18))),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[0]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                              )),
                        ),
                        onTap: () {
                          _showImage(context, images, 0);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _showImage(context, images, 1);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[1]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(18))),
                        ),
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
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[2]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 2);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[3]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 3);
                        },
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
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[4]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 4);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[5]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 5);
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
        break;
      case 7:
        imageWidget = Container(
          height: AdaptiveTools.setPx(165),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(18))),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[0]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                              )),
                        ),
                        onTap: () {
                          _showImage(context, images, 0);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[1]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 1);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[2]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 2);
                        },
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
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[3]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 3);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[4]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 4);
                        },
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
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[5]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 5);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[6]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 6);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      case 8:
        imageWidget = Container(
          height: AdaptiveTools.setPx(165),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(18))),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[0]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                              )),
                        ),
                        onTap: () {
                          _showImage(context, images, 0);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[1]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 1);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[2]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 2);
                        },
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
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[3]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 3);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[4]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 4);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[5]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 5);
                        },
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
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[6]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 6);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[7]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 7);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      case 9:
        imageWidget = Container(
          height: AdaptiveTools.setPx(165),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.all(Radius.circular(18))),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[0]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                              )),
                        ),
                        onTap: () {
                          _showImage(context, images, 0);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[1]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 1);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[2]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 2);
                        },
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
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[3]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 3);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[4]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 4);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[5]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 5);
                        },
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
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[6]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 6);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(images[7]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        onTap: () {
                          _showImage(context, images, 7);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(images[8]),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(18))),
                        ),
                        onTap: () {
                          _showImage(context, images, 8);
                        },
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

class TweetsOrReply extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Media extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Like extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
