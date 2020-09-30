
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/model/mypost_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/pages/home_detail_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/pages/post_publish_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/CacheImage.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/widget/fade_route.dart';
import 'package:flutter_mblog/widget/image_all_screen_look.dart';
import 'package:like_button/like_button.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class Tweets extends StatefulWidget {
  List<MyPostItem> _item;
  String userId;
  String loginUserId;
  String avatar;

  Tweets(this._item,this.userId,this.loginUserId,this.avatar);
  @override
  _TweetsState createState() => _TweetsState();
}

class _TweetsState extends State<Tweets> {
  void _deletePost(String id,BuildContext context) async {
    print("删除");
    PostDao.deletePost(id,context).then((value){
      if (value == "success") {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> MinePage(userid: widget.userId,)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int i = 0;
    return Column(
      children: widget._item.map((e) {
        return body(widget.userId,widget.loginUserId,e, context);
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

  Widget body(String userId,String loginUserId,MyPostItem _item, BuildContext context) {
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
                        child:ClipOval(
                          child: Image(
                            fit: BoxFit.cover,
                            image: OptimizedCacheImageProvider(_item.user.avatar),
                          ),
                        ),
                        width: AdaptiveTools.setRpx(80),
                        height:  AdaptiveTools.setRpx(80),
                      )/*Container(
                        margin: EdgeInsets.only(left: AdaptiveTools.setPx(7)),
                        alignment: Alignment.topLeft,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(_item.user.avatar),
                        ),
                      )*/,
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
                          width: AdaptiveTools.setRpx(320),
                          child: Text("@${_item.user.username}",overflow: TextOverflow.ellipsis,),
                        ),
                        Spacer(),
                        userId == loginUserId? InkWell(
                          child: Container(
                            alignment: Alignment.topRight,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black54,
                              size: AdaptiveTools.setPx(19),
                            ),
                          ),
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
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: ListView(
                                        children: <Widget>[
                                          ListTile(
                                            leading: Container(
                                              child: Image.asset("images/deletePost.png"),
                                              padding: EdgeInsets.all(15),
                                            ),
                                            title: Text("删除推文",style: TextStyle(fontSize: 15),),
                                            onTap: (){
                                              print("删除");
                                              showDialog(context: context,builder: (context){
                                                return AlertDialog(
                                                  content: Text('是否确认删除该帖子?'),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text('取消'),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                    FlatButton(
                                                      child: Text('确认'),
                                                      onPressed: () => _deletePost(_item.id,context),
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
                        ) : Container(),
                      ],
                    ),
                    InkWell(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: AdaptiveTools.setPx(3)),
                        child: Text(_item.content),
                      ),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeDetailPage(new PostItem(),postId: _item.id,)));
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8,bottom: 5),
                      child: image(_item.photos, context),
                    ),
                    if(_item.postId != null) _buildRetweet(_item.rPostItem),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeDetailPage(null,postId: _item.id,)));
                            },
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
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PostPublishPage(avatar:widget.avatar,postId: _item.id,)));
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

  Widget _buildRetweet(MyPostItem postItem) {
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
                        image: OptimizedCacheImageProvider(postItem.user.avatar),
                      ),
                    ),
                    width: AdaptiveTools.setRpx(50),
                    height:  AdaptiveTools.setRpx(50),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 8, 0, 10),
                        child: Text("${postItem.user.name}"),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 7, 10, 10),
                        child: Text("@${postItem.user.username}",style: TextStyle(color: Colors.black38),),
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
            builder: (context) => HomeDetailPage(new PostItem(),postId: postItem.id,)));
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