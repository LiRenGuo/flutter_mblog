import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/model/post_comment_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/widget/fade_route.dart';
import 'package:flutter_mblog/widget/image_all_screen_look.dart';
import 'package:flutter_mblog/widget/post_card.dart';
import 'package:flutter_mblog/widget/post_detail_card.dart';
import 'package:like_button/like_button.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class HomeDetailPage extends StatefulWidget {
  PostItem item;

  HomeDetailPage(this.item);

  @override
  _HomeDetailPageState createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> {
  bool isok = false;
  PostCommentModel _postCommentModel;
  TextEditingController _commentEditingController = new TextEditingController();
  FocusNode _commentFocus = FocusNode();
  List<Asset> fileList = List<Asset>();

  getPostDetail() async {
    PostCommentModel postCommentModel =
        await PostDao.getCommentList(widget.item.id);
    setState(() {
      _postCommentModel = postCommentModel;
      isok = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPostDetail();
  }

  @override
  Widget build(BuildContext context) {

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
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    PostDetailCard(item: widget.item),
                    Container(
                      height: 5,
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
              ),
              Container(
                height: 1,
                color: Colors.black12,
              ),
              Container(
                child: _bottomAction(widget.item),
                height: 58,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget commentist() {
    if (_postCommentModel.content.length != 0) {
      List<Widget> commentWidget = _postCommentModel.content.map((e) {
        print(e.photos.toString());
        return Container(
          child: Padding(
            padding: EdgeInsets.all(10),
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
                          )
                        ],
                      ),
                      SizedBox(
                        width: AdaptiveTools.setPx(10),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Text("${e.user.name}"),
                                ),
                                Container(
                                  child: Text("@${e.user.username}"),
                                ),
                                Container(
                                  child: Text(
                                      " · ${TimeUtil.parse(e.ctime.toString())}"),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Container(
                            child: Text(e.content),
                          ),
                          e.photos!=null && e.photos.isNotEmpty?image(e.photos):Container(width: 0,height: 0,),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
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
            margin: EdgeInsets.fromLTRB(5, 2, 0, 3),
            alignment: Alignment.centerLeft,
            child: Text(
              "评论",
              style: TextStyle(fontSize: AdaptiveTools.setPx(18)),
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
      return Container(
        margin: EdgeInsets.all(AdaptiveTools.setPx(10)),
        child: Text(
          "还没有评论",
          style: TextStyle(fontSize: AdaptiveTools.setPx(16)),
        ),
      );
    }
  }

  _showImage(BuildContext context,List<String> images, int index) {
    Navigator.of(context).push(FadeRoute(
        page: ImageAllScreenLook(
          imgDataArr:images,
          index: index,
        )
    ));
  }

  Widget image(List<String> images) {
    Widget imageWidget;
    switch (images.length) {
      case 1:
        imageWidget = InkWell(
          onTap: (){
            _showImage(context, images, 0);
          },
          child: Container(
            margin: EdgeInsets.only(top: 10),
            height: AdaptiveTools.setPx(165),
            width: AdaptiveTools.setPx(165),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(images[0]), fit: BoxFit.cover),
              border: Border.all(color: Colors.black26),
            ),
          ),
        );
        break;
      case 2:
        imageWidget = Row(
          children: <Widget>[
            InkWell(
              child: Container(
                margin: EdgeInsets.only(top: 10,bottom: 5),
                height: AdaptiveTools.setPx(165),
                width: AdaptiveTools.setPx(150),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(images[0]), fit: BoxFit.cover),
                  border: Border.all(color: Colors.black26),
                ),
              ),
              onTap: (){
                _showImage(context, images, 0);
              },
            ),
            SizedBox(width: AdaptiveTools.setPx(10),),
            InkWell(
              child: Container(
                margin: EdgeInsets.only(top: 10,bottom: 5),
                height: AdaptiveTools.setPx(165),
                width: AdaptiveTools.setPx(150),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(images[1]), fit: BoxFit.cover),
                  border: Border.all(color: Colors.black26),
                ),
              ),
              onTap: (){
                _showImage(context, images, 1);
              },
            )
          ],
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

  Future<void> sendComeent(PostItem item) async {
    PostCommentItem commentItem = await PostDao.sendComment(
        context, item.id, _commentEditingController.text,fileList);
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
        return onLike(isLiked, widget.item);
      },
      likeBuilder: (bool isLiked){
        return Image.asset(widget.item.islike ? 'images/ic_home_liked.webp' : 'images/ic_home_like.webp');
      },
      isLiked: widget.item.islike,
      likeCount: widget.item.likeCount,
      countBuilder: (int count, bool isLiked, String text) {
        final ColorSwatch<int> color = isLiked ? Colors.pinkAccent : Colors.grey;
        Widget result;
        if (count == 0) {
          result = Text(
            '赞',
            style: TextStyle(color: color),
          );
        } else
          result = Text(
            count >= 1000
                ? (count / 1000.0).toStringAsFixed(1) + 'k'
                : text,
            style: TextStyle(color: color),
          );

        return result;
      },
      likeCountAnimationType: widget.item.likeCount < 1000
          ? LikeCountAnimationType.part
          : LikeCountAnimationType.none,
    );
  }

  Future<bool> onLike(bool isLiked, PostItem postItem) {
    final Completer<bool> completer = new Completer<bool>();
    Timer(const Duration(milliseconds: 200), () {
      if(postItem.islike) {
        print("dislike...");
        PostDao.dislike(widget.item.id);
      } else {
        print("like...${widget.item.id}");
        PostDao.like(widget.item.id);
      }
      postItem.likeCount = postItem.islike ? widget.item.likeCount + 1 : widget.item.likeCount - 1;
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
                    return SingleChildScrollView(
                      child: Padding(
                        child: Container(
                          child: Column(
                            children: <Widget>[
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
                                                      color: Colors.black38)),
                                              contentPadding: EdgeInsets.all(10),
                                              hintText: "请输入你的评论"),
                                          maxLines: 4,
                                          controller: _commentEditingController,
                                        ),
                                        padding: EdgeInsets.all(3),
                                      )),
                                  Container(
                                    child: Column(
                                      children: <Widget>[
                                        InkWell(
                                          child: Container(
                                            child: Image.asset("images/Unfold.png"),
                                          ),
                                          onTap: () {
                                            print("Unfold");
                                          },
                                        ),
                                        SizedBox(height: AdaptiveTools.setPx(27),),
                                        InkWell(
                                          child: Container(
                                            child: Text("发送",style: TextStyle(color: Colors.white),),
                                            decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black54),
                                              color: Colors.black54
                                            ),
                                            padding: EdgeInsets.all(5),
                                          ),
                                          onTap: () {
                                            print("send");
                                            if (_commentEditingController.text.length !=
                                                0) {
                                              sendComeent(item);
                                              Navigator.pop(context);
                                            }
                                          },
                                        )
                                      ],
                                    ),
                                    margin: EdgeInsets.all(3),
                                  )
                                ],
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    InkWell(
                                      child: Stack(
                                        children: <Widget>[
                                          Container(
                                            child: Image.asset("images/icon_image.webp"),
                                            height:AdaptiveTools.setPx(23),
                                            margin: EdgeInsets.only(top: AdaptiveTools.setPx(3)),
                                          ),
                                          fileList.length != 0 ? Container(
                                            child: Text(fileList.length.toString(),style: TextStyle(fontSize: AdaptiveTools.setPx(9),color: Colors.white),),
                                            margin: EdgeInsets.only(left: AdaptiveTools.setPx(17)),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(50)),
                                                border: Border.all(color: Colors.red),
                                                color: Colors.red
                                            ),
                                            padding:EdgeInsets.only(left: AdaptiveTools.setPx(3)),
                                            height: AdaptiveTools.setPx(13),
                                            width: AdaptiveTools.setPx(13),
                                          ):Container(height: 0,width: 0,)
                                        ],
                                      ),
                                      onTap: (){
                                        _loadAssets();
                                      },
                                    ),
                                    Container(
                                      child: Image.asset("images/icon_mention.png"),
                                      height:AdaptiveTools.setPx(23),
                                      margin: EdgeInsets.only(top: AdaptiveTools.setPx(3)),
                                    ),
                                    Container(
                                      child: Image.asset("images/icon_topic.png"),
                                      height:AdaptiveTools.setPx(23),
                                      margin: EdgeInsets.only(top: AdaptiveTools.setPx(3)),
                                    ),
                                    Container(
                                      child: Image.asset("images/icon_gif.png"),
                                      height:AdaptiveTools.setPx(23),
                                      margin: EdgeInsets.only(top: AdaptiveTools.setPx(3)),
                                    ),
                                    Container(
                                      child: Image.asset("images/icon_emotion.png"),
                                      height:AdaptiveTools.setPx(23),
                                      margin: EdgeInsets.only(top: AdaptiveTools.setPx(3)),
                                    ),
                                    Container(
                                      child: Image.asset("images/icon_add.png"),
                                      height:AdaptiveTools.setPx(23),
                                      margin: EdgeInsets.only(top: AdaptiveTools.setPx(3)),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          height: AdaptiveTools.setPx(140),
                        ),
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),

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
    if(mounted) {
      setState(() {
        fileList = resultList;
      });
    }
  }
}
