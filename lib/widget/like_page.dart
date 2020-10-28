import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/model/post_like_model.dart';
import 'package:flutter_mblog/pages/home_detail_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/pages/post_publish_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/util/build_content.dart';
import 'package:flutter_mblog/util/image_process_tools.dart';
import 'package:flutter_mblog/widget/four_square_grid_image.dart';
import 'package:like_button/like_button.dart';

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
                            child: ImageProcessTools.CachedNetworkProcessImage(_item.userDto.avatar,memCacheWidth: 250,memCacheHeight: 250),
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
              SizedBox(width: 5,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text(
                              _item.userDto.name,
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
                              child: Text("@${_item.userDto.username}",overflow: TextOverflow.ellipsis,),
                            ),
                          )
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
                        child: BuildContent.buildContent(_item.content,context),
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
                      child: FourSquareGridImage.buildImage(context, _item.photos)/*image(_item.photos, context),*/
                    ),
                    if (_item.postId != null) _item.postId == "*" ?_buildRemoteRetweet():_buildRetweet(_item.rPostLikeItem),
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
                            onTap: (){
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
                      child: ImageProcessTools.CachedNetworkProcessImage(postItem.userDto.avatar,memCacheHeight: 250,memCacheWidth: 250),
                    ),
                    width: AdaptiveTools.setRpx(60),
                    height:  AdaptiveTools.setRpx(60),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 8, 0, 10),
                    child: Text("${postItem.userDto.name}"),
                  ),
                  Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(5, 9, 0, 10),
                        child: Text(
                          "@${postItem.userDto.username}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black38),
                        ),
                      )),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
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
                ? FourSquareGridImage.buildRetweetImage(postItem.photos)
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

  Widget _buildRemoteRetweet() {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(Icons.error,size: 14,color: Colors.red,),
          Text("原帖已删除",)
        ],
      ),
    );
  }

}
