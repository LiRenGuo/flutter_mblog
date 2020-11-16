import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/post_like_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/pages/home_detail_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/pages/post_publish_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/util/build_content.dart';
import 'package:flutter_mblog/util/image_process_tools.dart';
import 'package:flutter_mblog/widget/four_square_grid_image.dart';
import 'package:flutter_mblog/widget/retweet_widget.dart';
import 'package:flutter_mblog/widget/url_web_widget.dart';
import 'package:like_button/like_button.dart';

// ignore: must_be_immutable
class LikePage extends StatefulWidget {
  List<PostLikeItem> _item;
  String userId;
  String loginUserId;
  String avatar;

  LikePage(this._item, this.userId, this.loginUserId, this.avatar);

  @override
  _LikePageState createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
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
            style: TextStyle(color: color, fontSize: AdaptiveTools.setRpx(25)),
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
                                _item.userDto.avatar,
                                memCacheWidth: 450,
                                memCacheHeight: 450),
                          ),
                          width: AdaptiveTools.setRpx(90),
                          height: AdaptiveTools.setRpx(90),
                        ),
                      )
                    ],
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: Text(
                                _item.userDto.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 3),
                                child: Text(
                                  "@${_item.userDto.username}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12,color: Colors.grey),
                                ),
                              ),
                            ),
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
                              :  RetweetWidget(_item.userDto.avatar, _item.userDto.name, _item.userDto.username
                              , _item.rPostLikeItem.id, _item.rPostLikeItem.ctime.toString()
                              , _item.rPostLikeItem.content, _item.rPostLikeItem.photos),
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

  void _atToDetail(String name, BuildContext context) async {
    String id = await UserDao.getIdByName(name, context);
    if (id != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MinePage(
                    userid: id,
                    wLoginUserId: widget.userId,
                  )));
    }
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
