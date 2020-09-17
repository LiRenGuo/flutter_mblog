
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/model/mypost_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/pages/home_detail_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/widget/fade_route.dart';
import 'package:flutter_mblog/widget/image_all_screen_look.dart';
import 'package:like_button/like_button.dart';

class Tweets extends StatefulWidget {
  List<MyPostItem> _item;
  String userId;
  String loginUserId;

  Tweets(this._item,this.userId,this.loginUserId);
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
                        userId == loginUserId?InkWell(
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
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(25),
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
                        ):Container(),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    InkWell(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: AdaptiveTools.setPx(3)),
                        child: Text(_item.content),
                      ),
                      onTap: (){
                        print("跳转到某某地址");
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeDetailPage(new PostItem(),postId: _item.id,)));
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8,bottom: 8),
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