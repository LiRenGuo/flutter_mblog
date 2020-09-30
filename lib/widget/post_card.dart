import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/follow_dao.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/main.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/pages/home_detail_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/pages/post_publish_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/CacheImage.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/widget/image_all_screen_look.dart';
import 'package:like_button/like_button.dart';
import 'package:optimized_cached_image/image_cache_manager.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'fade_route.dart';

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
                child: Image(
                  fit: BoxFit.cover,
                  image: OptimizedCacheImageProvider(item.user.avatar),
                ),
              ),
              width: 60,
              height: 60,
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
                            Row(
                              children: <Widget>[
                                Container(
                                  child: Text(item.user.name,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: "sans-serif",
                                          fontWeight: FontWeight.w800)),
                                ),
                                Container(
                                  width: AdaptiveTools.setRpx(250),
                                  margin: EdgeInsets.only(left: 4, bottom: 2),
                                  child: Text("@${item.user.username}",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 13)),
                                ),
                              ],
                            ),
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
                      margin: EdgeInsets.only(top: 1, bottom: 4),
                      child: _content(context),
                    ),
                    //TODO
                    item.photos != null && item.photos.length != 0
                        ? _buildImage(item.photos)
                        : Container(),
                    _buildRetweet(item.forwardPost),
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

  Widget _buildRetweet(PostItem postItem) {
    Widget retweetWidget;
    postItem != null && postItem.id != null
        ? retweetWidget = InkWell(
            child: Container(
              margin: EdgeInsets.only(top: 10),
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
                        //TODO/*NetworkImage(postItem.user.avatar)*/
                        Container(
                          child: ClipOval(
                            child: Image(
                              fit: BoxFit.cover,
                              image: OptimizedCacheImageProvider(item.user.avatar),
                            ),
                          ),
                          width: 30,
                          height: 30,
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 8, 0, 10),
                              child: Text("${postItem.user.name}"),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(5, 7, 10, 10),
                              child: Text(
                                "@${postItem.user.username}",
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
                  // TODO
                  postItem.photos != null && postItem.photos.length != 0
                      ? _buildRetweetImage(postItem.photos)
                      : Container()
                ],
              ),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HomeDetailPage(
                        new PostItem(),
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

  Widget _buildImage(List<String> photos) {
    Widget imageWidget;
    switch (photos.length) {
      case 1:
        imageWidget = GestureDetector(
          child: Container(
              /*decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CacheImage(photos[0])
              )
            ),*/
              height: 150,
              width: double.infinity,
              margin: EdgeInsets.only(top: 3),
              child: ClipRRect(
                child: CacheImage.cachedImage(photos[0]),
                borderRadius: BorderRadius.circular(8),
              )),
          onTap: () => _showImage(context, 0),
        );
        break;
      case 2:
        imageWidget = Container(
          decoration:
              BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8))),
          height: 150,
          width: double.infinity,
          margin: EdgeInsets.only(top: 3),
          child: Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  child: Container(
                      height: double.infinity,
                      /*decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8)),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CacheImage(photos[0])
                      )
                    ),*/
                      child: ClipRRect(
                        child: CacheImage.cachedImage(photos[0]),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8)),
                      )),
                  onTap: () => _showImage(context, 0),
                ),
              ),
              SizedBox(
                width: 3,
              ),
              Expanded(
                child: GestureDetector(
                  child: Container(
                    height: double.infinity,
                    /*decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8)),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: CacheImage(photos[1])
                        )
                    ),*/
                    child: ClipRRect(
                      child: CacheImage.cachedImage(photos[1]),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8)),
                    ),
                  ),
                  onTap: () => _showImage(context, 1),
                ),
              )
            ],
          ),
        );
        break;
      case 3:
        imageWidget = Container(
          height: 150,
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
                          /*decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8)),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CacheImage(photos[0])
                              )
                          ),*/
                          child: ClipRRect(
                            child: CacheImage.cachedImage(photos[0]),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8)),
                          ),
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        onTap: () => _showImage(context, 0),
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
                                /*decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(8)),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CacheImage(photos[1])
                                    )
                                ),*/
                                child: ClipRRect(
                                  child: CacheImage.cachedImage(photos[1]),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context, 1),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                /*decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(8)),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CacheImage(photos[2])
                                    )
                                ),*/
                                child: ClipRRect(
                                  child: CacheImage.cachedImage(photos[2]),
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context, 2),
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
          height: 150,
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
                                /*decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8)),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CacheImage(photos[0])
                                    )
                                ),*/
                                child: ClipRRect(
                                  child: CacheImage.cachedImage(photos[0]),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context, 0),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                /*decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(8)),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CacheImage(photos[1])
                                    )
                                ),*/
                                child: ClipRRect(
                                  child: CacheImage.cachedImage(photos[1]),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context, 1),
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
                                /*decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(8)),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CacheImage(photos[2])
                                    )
                                ),*/
                                child: ClipRRect(
                                  child: CacheImage.cachedImage(photos[2]),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context, 2),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                /*decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(8)),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CacheImage(photos[3])
                                    )
                                ),*/
                                child: ClipRRect(
                                  child: CacheImage.cachedImage(photos[3]),
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context, 3),
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
        imageWidget = Container();
        break;
    }
    return imageWidget;
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
    TextStyle contentStyle = TextStyle(color: Colors.black, fontSize: 15);
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
    return Text(
      content,
      style: contentStyle,
      maxLines: 3,
      softWrap: true,
    );
  }

  _tapRecognizer(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeDetailPage(item)));
  }

  _showImage(BuildContext context, int index) {
    Navigator.of(context).push(FadeRoute(
        page: ImageAllScreenLook(
      imgDataArr: item.photos,
      index: index,
    )));
  }
}
