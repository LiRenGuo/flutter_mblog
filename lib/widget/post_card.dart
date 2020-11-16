import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/follow_dao.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/pages/home_detail_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/pages/post_publish_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/build_content.dart';
import 'package:flutter_mblog/util/image_process_tools.dart';
import 'package:flutter_mblog/widget/four_square_grid_image.dart';
import 'package:flutter_mblog/widget/retweet_widget.dart';
import 'package:flutter_mblog/widget/url_web_widget.dart';
import 'package:like_button/like_button.dart';

class PostCard extends StatefulWidget {
  final String avatar;
  final PostItem item;
  final int index;
  final String userId;

  const PostCard({Key key, this.item, this.index, this.userId, this.avatar})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  PostItem item;
  int index;

  @override
  void initState() {
    this.item = widget.item;
    this.index = widget.index;
    super.initState();
  }

  void _atToDetail(String name, BuildContext context) async {
    String id = await UserDao.getIdByName(name, context);
    if(id != null){
      Navigator.push(context, MaterialPageRoute(builder: (context) => MinePage(userid: id, wLoginUserId: widget.userId,)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            child: Container(
              child: ClipOval(
                child: ImageProcessTools.CachedNetworkProcessImage(
                    item.user.avatar,
                    memCacheHeight: 450,
                    memCacheWidth: 450),
              ),
              width: AdaptiveTools.setRpx(90),
              height: AdaptiveTools.setRpx(90),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MinePage(
                        userid: item.user.id,
                        wLoginUserId: widget.userId,
                  )));
            },
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10),
              child: InkWell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Text(item.user.name,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                            ),
                            Expanded(
                                child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(left: 4),
                              child: Text("@${item.user.username}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                            )),
                            Container(
                                margin: EdgeInsets.only(bottom: 2),
                                child: InkWell(
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 19,
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
                                              // TODO
                                              child: Column(
                                                children: <Widget>[
                                                  ListTile(
                                                    leading: Container(
                                                      child: item.user.isfollow
                                                          ? Image.asset(
                                                              "images/unattention.png")
                                                          : Image.asset(
                                                              "images/attention.png"),
                                                      padding:
                                                          EdgeInsets.all(14),
                                                    ),
                                                    title: item.user.isfollow
                                                        ? Text(
                                                            "取消关注 @${item.user.name}",
                                                            style: TextStyle(
                                                                fontSize: 15),
                                                          )
                                                        : Text(
                                                            "关注 @${item.user.name}",
                                                            style: TextStyle(
                                                                fontSize: 15),
                                                          ),
                                                    onTap: () {
                                                      item.user.isfollow
                                                          ? _unfollowYou(
                                                              item.user.id)
                                                          : _followYou(
                                                              item.user.id);
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
                                ))
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MinePage(
                                  userid: item.user.id,
                                )));
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                      child: _content(context),
                    ),
                    item.photos != null && item.photos.length != 0
                        ? FourSquareGridImage.buildImage(context, item.photos)
                        : Container(),
                    if (item.postId != null)
                      item.postId == "*"
                          ? _buildRemoteRetweet()
                          : RetweetWidget(item.user.avatar, item.user.name, item.user.username
                          , item.forwardPost.id, item.forwardPost.ctime.toString()
                          , item.forwardPost.content, item.forwardPost.photos),
                    if (item.website != null) UrlWebWidget(item.website),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _buildLikeButton(),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => HomeDetailPage(item)));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'images/ic_home_comment.webp',
                                  width: 22,
                                  height: 22,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 4),
                                  child: Text(
                                      item.commentCount == 0
                                          ? '评论'
                                          : item.commentCount.toString(),
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 13)),
                                )
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PostPublishPage(
                                        avatar: widget.avatar,
                                        postItem: item,
                                      )));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'images/ic_home_forward.png',
                                  width: 22,
                                  height: 22,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 4),
                                  child: Text(
                                      item.forwardCount == 0
                                          ? '转发'
                                          : item.forwardCount.toString(),
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 13)),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => HomeDetailPage(item)));
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  _followYou(String userId) {
    FollowDao.follow(userId, context);
    Navigator.pop(context);
    if (mounted) {
      setState(() {
        item.user.isfollow = true;
      });
    }
  }

  _unfollowYou(String userId) {
    FollowDao.unfollow(userId, context);
    Navigator.pop(context);
    if (mounted) {
      setState(() {
        item.user.isfollow = false;
      });
    }
  }

  _buildLikeButton() {
    return LikeButton(
      size: 22,
      onTap: (bool isLiked) {
        return onLike(isLiked, item);
      },
      likeBuilder: (bool isLiked) {
        return Image.asset(item.islike
            ? 'images/ic_home_liked.webp'
            : 'images/ic_home_like.webp');
      },
      isLiked: item.islike,
      likeCount: item.likeCount,
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
          result = Container(
            child: Text(
              count >= 1000 ? (count / 1000.0).toStringAsFixed(1) + 'k' : text,
              style: TextStyle(color: color),
            ),
            margin: EdgeInsets.only(left: 2),
          );

        return result;
      },
      likeCountAnimationType: item.likeCount < 1000
          ? LikeCountAnimationType.part
          : LikeCountAnimationType.none,
    );
  }

  Future<bool> onLike(bool isLiked, PostItem postItem) {
    final Completer<bool> completer = new Completer<bool>();
    Timer(const Duration(milliseconds: 200), () {
      if (postItem.islike) {
        print("dislike...");
        PostDao.dislike(postItem.id);
      } else {
        print("like...${item.id}");
        PostDao.like(postItem.id);
      }
      postItem.likeCount =
          postItem.islike ? item.likeCount - 1 : item.likeCount + 1;
      postItem.islike = !postItem.islike;
      completer.complete(postItem.islike);
    });
    return completer.future;
  }

  _content(BuildContext context) {
    String content = item.content;
    TextStyle contentStyle = TextStyle(color: Colors.black, fontSize: 16);
    if (content.length > 150) {
      content = content.substring(0, 148) + ' ... ';
      return RichText(
          text: TextSpan(
        children: [
          TextSpan(text: content, style: contentStyle),
          TextSpan(
              text: '全文',
              style: TextStyle(color: Colors.blue, fontSize: 16),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _tapRecognizer(context))
        ],
      ));
    }
    return BuildContent.buildContent(content,context,
        maxLines: 3,
        softWrap: true,
        atOnTap: (name) => _atToDetail(name, context));
  }

  _tapRecognizer(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeDetailPage(item)));
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
