import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/follow_dao.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/mypost_model.dart';
import 'package:flutter_mblog/model/post_comment_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:flutter_mblog/widget/fade_route.dart';
import 'package:flutter_mblog/widget/image_all_screen_look.dart';
import 'package:flutter_mblog/widget/post_detail_card.dart';
import 'package:like_button/like_button.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

// ignore: must_be_immutable
class HomeDetailPage extends StatefulWidget {
  PostItem item;
  String postId;
  HomeDetailPage(this.item,{this.postId});

  @override
  _HomeDetailPageState createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> {
  PostItem _item;
  bool isok = false;
  bool initPostItemOk = false;
  PostCommentModel _postCommentModel;
  TextEditingController _commentEditingController = new TextEditingController();
  List<Asset> fileList = List<Asset>();
  bool isOkAttention;
  List<String> isAttention;

  initPostItem()async{
    PostItem _itemWidget;
    if (widget.postId != null) {
      _itemWidget =  await PostDao.getPostById(widget.postId,context);
    }
    if (mounted) {
      setState(() {
        if (widget.postId != null) {
          _item = _itemWidget;
        }else{
          _item = widget.item;
        }
        if (_item != null) {
          initPostItemOk = true;
        }
      });
    }
  }

  getPostDetail() async {
    PostCommentModel postCommentModel;
    if (widget.postId != null) {
      postCommentModel = await PostDao.getCommentList(widget.postId);
    }else{
      postCommentModel = await PostDao.getCommentList(widget.item.id);
    }
    setState(() {
      _postCommentModel = postCommentModel;
      isok = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPostItem();
    getPostDetail();
    initAttention();
  }

  Future<Null> _onRefresh() async {
    setState(() {
      initPostItem();
      getPostDetail();
      initAttention();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("内容为"+_item.toString());
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.blue),
          title: Text(
            "正文",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: initPostItemOk?Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  child: ListView(
                    children: <Widget>[
                      PostDetailCard(item: _item),
                      Container(
                        height: 4,
                        color: Colors.black12,
                      ),
                      isok
                          ? commentist()
                          : Container(
                        height: 0,
                        width: 0,
                      )
                    ],
                  ),
                  onRefresh: _onRefresh,
                ),
              ),
              Container(
                height: 1,
                color: Colors.black12,
              ),
              Container(
                child: _bottomAction(_item),
                height: 58,
              )
            ],
          ),
        ):Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  initAttention() async {
    UserModel userModel = await Shared_pre.Shared_getUser();
    FollowModel followModel =  await UserDao.getFollowingList(userModel.id,context);
    List<String> isAtt = [];
    if (followModel != null && followModel.followList.length != 0) {
      var isAttList =  followModel.followList.map((e)=>e.id);
      isAtt.addAll(isAttList);
    }
    if (mounted) {
      setState(() {
        isOkAttention = true;
        isAttention = isAtt;
      });
    }
  }

  _followYou(String userId){
    print(userId);
    FollowDao.follow(userId, context);
    Navigator.pop(context);
    if (mounted) {
      setState(() {
        initAttention();
      });
    }
  }

  _unfollowYou(String userId){
    print(userId);
    FollowDao.unfollow(userId, context);
    Navigator.pop(context);
    if (mounted) {
      setState(() {
        initAttention();
      });
    }
  }

  Widget commentist() {
    if (_postCommentModel.content.length != 0) {
      List<Widget> commentWidget = _postCommentModel.content.map((e) {
        print(e.photos.toString());
        return Container(
          child: Padding(
            padding: EdgeInsets.fromLTRB(10,10,10,0),
            child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: NetworkImage(e.user.avatar),
                            radius: 25
                          )
                        ],
                      ),
                      SizedBox(
                        width: AdaptiveTools.setPx(10),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        child: Text("${e.user.name}"),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(left: 5,bottom: 1),
                                        child: Text("@${e.user.username}"),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text(
                                            " · ${TimeUtil.parse(e.ctime.toString())}"),
                                      )
                                    ],
                                  ),
                                  InkWell(
                                    child: Container(child: Icon(Icons.keyboard_arrow_down),),
                                    onTap: (){
                                      print("关注");
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
                                                        child: isAttention.contains(e.user.id)?Image.asset("images/unattention.png"):Image.asset("images/attention.png"),
                                                        padding: EdgeInsets.all(14),
                                                      ),
                                                      title: isAttention.contains(e.user.id) ?Text("取消关注 @${e.user.name}",style: TextStyle(fontSize: 15),):Text("关注 @${e.user.name}",style: TextStyle(fontSize: 15),),
                                                      onTap: (){
                                                        isAttention.contains(e.id)?_unfollowYou(e.user.id):_followYou(e.user.id);
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
                                  )
                                ],
                              ),
                              width:AdaptiveTools.setRpx(575),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              child: Text(e.content),
                            ),
                            e.photos != null && e.photos.isNotEmpty
                                ? image(e.photos)
                                : Container(
                              width: 0,
                              height: 0,
                            ),
                          ],
                        ),
                        margin: EdgeInsets.only(top: 1),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 1,
                  color: Colors.black12,
                )
              ],
            ),
          ),
        );
      }).toList();
      commentWidget.insert(
          0,
          Container(
            margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
            alignment: Alignment.centerLeft,
            child: Text(
              "回复",
              style: TextStyle(fontSize: AdaptiveTools.setPx(16),color: Colors.black54),
            ),
          ));
      commentWidget.insert(
          1,
          Container(
            height: 1,
            color: Colors.black12,
          ));
      return Column(
        children: commentWidget,
      );
    } else {
      return Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10, 5, 0, 5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "评论",
                    style: TextStyle(fontSize: AdaptiveTools.setPx(16),color: Colors.black54),
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.black12,
                )
              ],
            ),
          ),
          Container(
            height: 280,
            alignment: Alignment.center,
            width: double.infinity,
            child: Text("快来发表你的评论",style: TextStyle(color: Colors.black54,fontSize: 14),),
          )
        ],
      );
    }
  }

  _showImage(BuildContext context, List<String> images, int index) {
    Navigator.of(context).push(FadeRoute(
        page: ImageAllScreenLook(
      imgDataArr: images,
      index: index,
    )));
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

  Widget image(List<String> images) {
    Widget imageWidget;
    switch (images.length) {
      case 1:
        imageWidget = GestureDetector(
          child: Container(
            height: AdaptiveTools.setPx(165),
            width: AdaptiveTools.setRpx(575),
            margin: EdgeInsets.only(top: 10),
            child: ClipRRect(
              child: _cachedImage(images[0]),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onTap: () => _showImage(context,images, 0),
        );
        break;
      case 2:
        imageWidget = Container(
          height: AdaptiveTools.setPx(165),
          width: AdaptiveTools.setRpx(575),
          margin: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: GestureDetector(
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: ClipRRect(
                      child: _cachedImage(images[0]),
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
              Flexible(
                child: GestureDetector(
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: ClipRRect(
                      child: _cachedImage(images[0]),
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

        /*imageWidget = Container(
          width: AdaptiveTools.setPx(100),
          child: Row(
            children: <Widget>[
              InkWell(
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 5),
                  height: AdaptiveTools.setPx(165),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(images[0]), fit: BoxFit.cover),
                    border: Border.all(color: Colors.black26),
                  ),
                ),
                onTap: () {
                  _showImage(context, images, 0);
                },
              ),
              SizedBox(
                width: AdaptiveTools.setPx(10),
              ),
              InkWell(
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 5),
                  height: AdaptiveTools.setPx(165),
                  width: AdaptiveTools.setPx(100),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(images[1]), fit: BoxFit.cover),
                    border: Border.all(color: Colors.black26),
                  ),
                ),
                onTap: () {
                  _showImage(context, images, 1);
                },
              )
            ],
          ),
        );*/
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

  Future<void> sendComeent(PostItem item) async {
    PostCommentItem commentItem = await PostDao.sendComment(
        context, item.id, _commentEditingController.text, fileList);
    setState(() {
      _postCommentModel.content.insert(0, commentItem);
      _commentEditingController.text = "";
      fileList.clear();
    });
  }

  _buildLikeButton() {
    return LikeButton(
      size: 22,
      onTap: (bool isLiked) {
        return onLike(isLiked, _item);
      },
      likeBuilder: (bool isLiked) {
        return Image.asset(_item.islike
            ? 'images/ic_home_liked.webp'
            : 'images/ic_home_like.webp');
      },
      isLiked: _item.islike,
      likeCount: _item.likeCount,
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
      likeCountAnimationType: _item.likeCount < 1000
          ? LikeCountAnimationType.part
          : LikeCountAnimationType.none,
    );
  }

  Future<bool> onLike(bool isLiked, PostItem postItem) {
    final Completer<bool> completer = new Completer<bool>();
    Timer(const Duration(milliseconds: 200), () {
      if (postItem.islike) {
        print("dislike...");
        PostDao.dislike(_item.id);
      } else {
        print("like...${_item.id}");
        PostDao.like(_item.id);
      }
      postItem.likeCount = postItem.islike
          ? _item.likeCount + 1
          : _item.likeCount - 1;
      postItem.islike = !postItem.islike;
      completer.complete(postItem.islike);
    });
    return completer.future;
  }

  _bottomAction(PostItem item) {
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
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(bottom:MediaQuery.of(context).viewInsets.bottom),
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            // 输入框
                            Row(
                              children: <Widget>[
                                Expanded(
                                    child: Container(
                                      child: TextField(
                                        autofocus: true,
                                        decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.black38)),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.blueAccent)),
                                            contentPadding: EdgeInsets.all(10),
                                            hintText: "请输入你的评论"),
                                        controller: _commentEditingController,
                                      ),
                                      padding: EdgeInsets.all(5),
                                      height: 50,
                                    ),
                                  flex: 10,
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 5,right: 10),
                                  height: 45,
                                  width: AdaptiveTools.setRpx(200),
                                  alignment: Alignment.bottomCenter,
                                  child: RaisedButton(
                                    child: Text("发送"),
                                    onPressed: (){
                                      if (_commentEditingController
                                          .text.length !=
                                          0) {
                                        sendComeent(item);
                                        Navigator.pop(context);
                                      }
                                    },
                                    color: Colors.blue,
                                    textColor: Colors.white,
                                  )
                                )
                              ],
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  InkWell(
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          child: Image.asset(
                                              "images/icon_image.webp"),
                                          height: AdaptiveTools.setPx(23),
                                          margin: EdgeInsets.only(
                                              top: AdaptiveTools.setPx(3)),
                                        ),
                                        fileList.length != 0
                                            ? Container(
                                          child: Text(
                                            fileList.length.toString(),
                                            style: TextStyle(
                                                fontSize:
                                                AdaptiveTools.setPx(
                                                    9),
                                                color: Colors.white),
                                          ),
                                          margin: EdgeInsets.only(
                                              left: AdaptiveTools.setPx(
                                                  17)),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.all(
                                                  Radius.circular(
                                                      50)),
                                              border: Border.all(
                                                  color: Colors.red),
                                              color: Colors.red),
                                          padding: EdgeInsets.only(
                                              left: AdaptiveTools.setPx(
                                                  3)),
                                          height:
                                          AdaptiveTools.setPx(13),
                                          width:
                                          AdaptiveTools.setPx(13),
                                        )
                                            : Container(
                                          height: 0,
                                          width: 0,
                                        )
                                      ],
                                    ),
                                    onTap: () {
                                      _loadAssets();
                                    },
                                  ),
                                  Container(
                                    child: Image.asset(
                                        "images/icon_mention.png"),
                                    height: AdaptiveTools.setPx(23),
                                    margin: EdgeInsets.only(
                                        top: AdaptiveTools.setPx(3)),
                                  ),
                                  Container(
                                    child:
                                    Image.asset("images/icon_topic.png"),
                                    height: AdaptiveTools.setPx(23),
                                    margin: EdgeInsets.only(
                                        top: AdaptiveTools.setPx(3)),
                                  ),
                                  Container(
                                    child: Image.asset("images/icon_gif.png"),
                                    height: AdaptiveTools.setPx(23),
                                    margin: EdgeInsets.only(
                                        top: AdaptiveTools.setPx(3)),
                                  ),
                                  Container(
                                    child: Image.asset(
                                        "images/icon_emotion.png"),
                                    height: AdaptiveTools.setPx(23),
                                    margin: EdgeInsets.only(
                                        top: AdaptiveTools.setPx(3)),
                                  ),
                                  Container(
                                    child: Image.asset("images/icon_add.png"),
                                    height: AdaptiveTools.setPx(23),
                                    margin: EdgeInsets.only(
                                        top: AdaptiveTools.setPx(3)),
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.only(bottom: 10),
                            ),
                            // 底部导航栏
                          ],
                        ),
                        height: AdaptiveTools.setRpx(180),
                      ),
                    );
                  });
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

  // 打开系统相册
  Future<void> _loadAssets() async {
    List<Asset> resultList = fileList;
    try {
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: fileList,
        maxImages: 2, //最多9张
        enableCamera: true,
      );
    } catch (e) {
      print(e.toString());
    }
    if (mounted) {
      setState(() {
        fileList = resultList;
      });
    }
  }
}
