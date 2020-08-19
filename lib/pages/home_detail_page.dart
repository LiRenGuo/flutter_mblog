import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/model/post_comment_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/widget/post_card.dart';
import 'package:flutter_mblog/widget/post_detail_card.dart';

class HomeDetailPage extends StatefulWidget {
  PostItem item;

  HomeDetailPage(this.item);

  @override
  _HomeDetailPageState createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> {
  bool isok = false;
  PostCommentModel _postCommentModel;

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
                    isok ? commentist() : Container(
                      height: 0,
                      width: 0,
                    )
                  ],
                ),
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

  Widget commentist(){
    if (_postCommentModel.content.length != 0) {
      List<Widget> commentWidget = _postCommentModel.content.map((e) {
        return Container(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Container (
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
                      SizedBox(width: AdaptiveTools.setPx(10),),
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
                                  child: Text(" · ${TimeUtil.parse(e.ctime.toString())}"),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 100,),
                          Container(
                            child: Text(e.content),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }).toList();
      return Column(
        children: commentWidget,
      );
    }else{
      return Container(
        child: Text("暂无数据"),
      );
    }
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
              print("clicked...");
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
          child: InkWell(
            onTap: () {
              print("clicked...");
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  item.islike
                      ? 'images/ic_home_liked.webp'
                      : 'images/ic_home_like.webp',
                  width: 22,
                  height: 22,
                ),
                Container(
                  margin: EdgeInsets.only(left: 4),
                  child: Text(
                      item.likeCount == 0 ? '赞' : item.likeCount.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 13)),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
