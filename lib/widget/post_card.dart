import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/follow_dao.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/pages/home_detail_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/pages/my_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/widget/image_all_screen_look.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:like_button/like_button.dart';
import 'fade_route.dart';

class PostCard extends StatefulWidget {
  final PostItem item;
  final int index;
  final String userId;

  const PostCard({Key key, this.item, this.index, this.userId})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  PostItem item;
  int index;
  bool isAttention;
  bool isOkAttention = false;

  @override
  void initState() {
    this.item = widget.item;
    this.index = widget.index;
    this.isAttention = false;
    initAttention();
    super.initState();
  }

  initAttention() async {
    FollowModel followModel =  await UserDao.getFollowingList(widget.userId);
    if (followModel != null && followModel.followList.length != 0) {
      bool isAtt = false;
      followModel.followList.forEach((element) {
        if (element.id == item.user.id) {
          isAtt = true;
        }
      });
      if (mounted) {
        setState(() {
          isOkAttention = true;
          isAttention = isAtt;
        });
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
          children: <Widget>[
            InkWell(
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.black,
                backgroundImage: NetworkImage(item.user.avatar),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MinePage(userid: item.user.id,wLoginUserId: widget.userId,)));
              },
            ),
            Container(
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
                                    margin: EdgeInsets.only(left: 3, bottom: 1),
                                    child: Text("@${item.user.username}",
                                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                                  ),
                                  Container(
                                    child: Text(" · "+TimeUtil.parse(item.ctime.toString()),
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                    margin: EdgeInsets.only(left: 3, bottom: 4),
                                  )
                                ],
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: InkWell(
                                    child: Icon(Icons.keyboard_arrow_down,size: 19,),
                                    onTap: (){
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
                                                    topLeft: Radius.circular(25),
                                                    topRight: Radius.circular(25),
                                                  ),
                                                ),
                                                child: ListView(
                                                  children: <Widget>[
                                                    isOkAttention ?
                                                    ListTile(
                                                      leading: Container(
                                                        child: isAttention?Image.asset("images/unattention.png"):Image.asset("images/attention.png"),
                                                        padding: EdgeInsets.all(10),
                                                      ),
                                                      title: isAttention ?Text("取消关注 @${item.user.name}",style: TextStyle(fontSize: 15),):Text("关注 @${item.user.name}",style: TextStyle(fontSize: 15),),
                                                      onTap: (){
                                                        isAttention?_unfollowYou(item.user.id):_followYou(item.user.id);
                                                      },
                                                    ):Container()
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
                          width:AdaptiveTools.setPx(290)
                      ),
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => MinePage(userid: item.user.id,)));
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 1, bottom: 4),
                      child: _content(context),
                      width: AdaptiveTools.setPx(290),
                    ),
                    item.photos != null && item.photos.length != 0
                        ? _buildImage(item.photos)
                        : Container(),
                    Container(
                      width: AdaptiveTools.setPx(290),
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
                              print("clicked...");
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
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeDetailPage(item)));
                },
              ),
            )
          ],
        ));
    /*Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(item.user.avatar),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(item.user.name,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Row(
                                children: <Widget>[
                                  Text(TimeUtil.parse(item.ctime.toString()),
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Text('来自 ${item.devicemodel}',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                  )
                                ],
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MinePage(userid: item.user.id,)));
              },
            ),
            InkWell(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    child: _content(context),
                  ),
                  if (item.photos.length != 0) _photoItem(context),
                ],
              ),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HomeDetailPage(item)));
              },
            ),
            Divider(
              height: 20.0,
            ),
            _bottomAction()
          ],
        )*/
  }

  _followYou(String userId){
    print(userId);
    FollowDao.follow(userId, context);
    Navigator.pop(context);
    if (mounted) {
      setState(() {
        isAttention = true;
      });
    }
  }

  _unfollowYou(String userId){
    print(userId);
    FollowDao.unfollow(userId, context);
    Navigator.pop(context);
    if (mounted) {
      setState(() {
        isAttention = false;
      });
    }
  }

  Widget _buildImage(List<String> photos) {
    Widget imageWidget;
    switch (photos.length) {
      case 1:
        imageWidget = GestureDetector(
          child: Container(
            height: 200,
            width: AdaptiveTools.setPx(290),
            margin: EdgeInsets.only(top: 3),
            child: ClipRRect(
              child: _cachedImage(photos[0]),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onTap: () => _showImage(context, 0),
        );
        break;
      case 2:
        imageWidget = Container(
          height: 200,
          width: AdaptiveTools.setPx(290),
          margin: EdgeInsets.only(top: 3),
          child: Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  child: Container(
                    height: double.infinity,
                    child: ClipRRect(
                      child: _cachedImage(photos[0]),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                    ),
                  ),
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
                    child: ClipRRect(
                      child: _cachedImage(photos[1]),
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
          height: 200,
          width: AdaptiveTools.setPx(290),
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
                            child: _cachedImage(photos[0]),
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
                                child: ClipRRect(
                                  child: _cachedImage(photos[1]),
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
                                child: ClipRRect(
                                  child: _cachedImage(photos[2]),
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
          height: 200,
          width: AdaptiveTools.setPx(290),
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
                                  child: _cachedImage(photos[0]),
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
                                child: ClipRRect(
                                  child: _cachedImage(photos[1]),
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
                                child: ClipRRect(
                                  child: _cachedImage(photos[2]),
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
                                child: ClipRRect(
                                  child: _cachedImage(photos[3]),
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

  _buildAttention() {
    return widget.userId != item.user.id
        ? Expanded(
            child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+ 关注',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                )),
          )
        : Container();
  }

  _photoItem(BuildContext context) {
    if (item.photos.length == 1) {
      return GestureDetector(
        onTap: () => _showImage(context, 1),
        child: Container(
          height: 200,
          margin: EdgeInsets.only(top: 10),
          child: ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: _cachedImage(item.photos[0]),
          ),
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.only(top: 10),
        child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            physics: NeverScrollableScrollPhysics(),
            children: _buildList(context)),
      );
    }
  }

  List<Widget> _buildList(BuildContext context) {
    return Iterable.generate(item.photos.length)
        .map((index) => _item(item.photos[index], index, context))
        .toList();
  }

  Widget _item(String img, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => _showImage(context, index),
      child: Container(
        child: _cachedImage(img),
      ),
    );
  }

  _cachedImage(String img) {
    return CachedNetworkImage(
      imageUrl: img,
      fit: BoxFit.cover,
      placeholder: (context, url) {
        return Container(
          height: 20,
          child: Center(child: Center(
            child: CircularProgressIndicator(),
          )),
        );
      },
    );
  }

  _bottomAction() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: InkWell(
            onTap: () {
              print("clicked...");
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
                      style: TextStyle(color: Colors.black, fontSize: 13)),
                )
              ],
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: InkWell(
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
                      style: TextStyle(color: Colors.black, fontSize: 13)),
                )
              ],
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: _buildLikeButton(),
        )
      ],
    );
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
    return Text(content, style: contentStyle,maxLines: 3,softWrap: true,);
  }

  bool isExpansion(String text) {
    TextPainter _textPainter = TextPainter(
        maxLines: 3,
        text: TextSpan(
          text: text,
          style: TextStyle(color: Colors.black, fontSize: 15)
        ),
        textDirection: TextDirection.ltr)
      ..layout(
          maxWidth: MediaQuery.of(context).size.width,
          minWidth: MediaQuery.of(context).size.width);
    if (_textPainter.didExceedMaxLines) {
      return true;
    } else {
      return false;
    }
  }

  _tapRecognizer(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomeDetailPage(item)));
  }

  _showImage(BuildContext context, int index) {
    Navigator.of(context).push(FadeRoute(
        page: ImageAllScreenLook(
      imgDataArr: item.photos,
      index: index,
    )));
  }
}
