import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/mypost_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/pages/home_detail_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/pages/post_publish_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/util/build_content.dart';
import 'package:flutter_mblog/util/image_process_tools.dart';
import 'package:flutter_mblog/widget/browser_page.dart';
import 'package:flutter_mblog/widget/four_square_grid_image.dart';
import 'package:flutter_mblog/widget/retweet_widget.dart';
import 'package:flutter_mblog/widget/url_web_widget.dart';
import 'package:like_button/like_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Tweets extends StatefulWidget {
  List<MyPostItem> _item;
  String userId;
  String loginUserId;
  String avatar;
  bool isTabNav;
  final refreshPage;

  Tweets(this._item, this.userId, this.loginUserId, this.avatar, this.isTabNav,
      this.refreshPage);

  @override
  _TweetsState createState() => _TweetsState();
}

class _TweetsState extends State<Tweets> {
  void _deletePost(String id, BuildContext context) async {
    PostDao.deletePost(id, context).then((value) {
      if (value == "success") {
        Navigator.pop(context);
        Navigator.pop(context);
        widget.refreshPage(true);
      }
    });
  }

  void _atToDetail(String name, BuildContext context) async {
    String id = await UserDao.getIdByName(name, context);
    if (id != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MinePage(
                    userid: id,
                    wLoginUserId: widget.loginUserId,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget._item.map((e) {
        return body(widget.userId, widget.loginUserId, e, context);
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

  Widget body(String userId, String loginUserId, MyPostItem _item,
      BuildContext context) {
    return InkWell(
      child: Padding(
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
                          child: ClipOval(
                            child: ImageProcessTools.CachedNetworkProcessImage(
                                _item.user.avatar,
                                memCacheWidth: 250,
                                memCacheHeight: 250),
                          ),
                          width: AdaptiveTools.setRpx(80),
                          height: AdaptiveTools.setRpx(80),
                        ),
                      )
                    ],
                  ),
                  flex: 1,
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            child: Text(
                              _item.user.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                letterSpacing: 2,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            margin: EdgeInsets.only(right: 5),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                "@${_item.user.username}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12,color: Colors.black38),
                              ),
                            ),
                          ),
                          userId == loginUserId
                              ? InkWell(
                                  child: Container(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.black54,
                                      size: AdaptiveTools.setPx(19),
                                    ),
                                  ),
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Stack(
                                          children: <Widget>[
                                            Container(
                                              height: 25,
                                              width: double.infinity,
                                              color: Colors.black54,
                                            ),
                                            Container(
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                ),
                                              ),
                                              child: ListView(
                                                children: <Widget>[
                                                  ListTile(
                                                    leading: Container(
                                                      child: Image.asset(
                                                          "images/deletePost.png"),
                                                      padding:
                                                          EdgeInsets.all(15),
                                                    ),
                                                    title: Text(
                                                      "删除推文",
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                    ),
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              content: Text(
                                                                  '是否确认删除该帖子?'),
                                                              actions: <Widget>[
                                                                FlatButton(
                                                                  child: Text(
                                                                      '取消'),
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                ),
                                                                FlatButton(
                                                                  child: Text(
                                                                      '确认'),
                                                                  onPressed: () =>
                                                                      _deletePost(
                                                                          _item
                                                                              .id,
                                                                          context),
                                                                )
                                                              ],
                                                            );
                                                          });
                                                    },
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                )
                              : Container(),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: AdaptiveTools.setPx(3)),
                        child: BuildContent.buildContent(_item.content, context,
                            atOnTap: (name) => _atToDetail(name, context)),
                      ),
                      if(_item.photos != null && _item.photos.length != 0) Container(
                          margin: EdgeInsets.only(top: 5),
                          child: FourSquareGridImage.buildImage(context, _item.photos)
                      ),
                      if (_item.postId != null)
                        _item.postId == "*"
                            ? _buildRemoteRetweet()
                            :  RetweetWidget(_item.user.avatar, _item.user.name, _item.user.username
                                    , _item.rPostItem.id, _item.rPostItem.ctime.toString()
                                    , _item.rPostItem.content, _item.rPostItem.photos),
                      if (_item.website != null) UrlWebWidget(_item.website),
                      SizedBox(height: 5,),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: _buildLikeButton(_item),
                              height: AdaptiveTools.setPx(20),
                            ),
                            InkWell(
                              child: Container(
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
                            InkWell(
                              child: Container(
                                child:
                                    Image.asset("images/ic_home_forward.png"),
                                height: AdaptiveTools.setPx(20),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PostPublishPage(
                                              avatar: widget.avatar,
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
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeDetailPage(
                      new PostItem(),
                      postId: _item.id,
                    )));
      },
    );
  }

  Widget _buildRemoteRetweet() {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            Icons.error,
            size: 14,
            color: Colors.red,
          ),
          Text(
            "原帖已删除",
          )
        ],
      ),
    );
  }
}
