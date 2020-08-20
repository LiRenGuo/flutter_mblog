import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/pages/home_detail_page.dart';
import 'package:flutter_mblog/pages/my_page.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/widget/image_all_screen_look.dart';
import 'package:like_button/like_button.dart';
import 'fade_route.dart';

class PostCard extends StatefulWidget {

  final PostItem item;
  final int index;

  const PostCard({Key key, this.item, this.index}) : super(key: key);

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
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
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
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    child: _content(context),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => HomeDetailPage(item)));
                    },
                  ),
                ),
                if (item.photos.length != 0) _photoItem(context),
              ],
            ),
            Divider(
              height: 20.0,
            ),
            _bottomAction()
          ],
        ));
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
    return Iterable.generate(item.photos.length).map((index) => _item(item.photos[index], index, context)).toList();
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
          child: Center(child: CircularProgressIndicator()),
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
      likeBuilder: (bool isLiked){
        return Image.asset(item.islike ? 'images/ic_home_liked.webp' : 'images/ic_home_like.webp');
      },
      isLiked: item.islike,
      likeCount: item.likeCount,
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
      likeCountAnimationType: item.likeCount < 1000
          ? LikeCountAnimationType.part
          : LikeCountAnimationType.none,
    );
  }

  Future<bool> onLike(bool isLiked, PostItem postItem) {
    final Completer<bool> completer = new Completer<bool>();
    Timer(const Duration(milliseconds: 200), () {
      if(postItem.islike) {
        print("dislike...");
        PostDao.dislike(postItem.id);
      } else {
        print("like...${item.id}");
        PostDao.like(postItem.id);
      }
      postItem.likeCount = postItem.islike ? item.likeCount + 1 : item.likeCount - 1;
      postItem.islike = !postItem.islike;
      completer.complete(postItem.islike);
    });
    return completer.future;
  }

  _content(BuildContext context) {
    String content = item.content;
    TextStyle contentStyle = TextStyle(color: Colors.black, fontSize: 16);
    //如果字数过长
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
    return Text(content, style: contentStyle);
  }

  _tapRecognizer(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
  }

  _showImage(BuildContext context, int index) {
    Navigator.of(context).push(FadeRoute(
        page: ImageAllScreenLook(
          imgDataArr:item.photos,
          index: index,
        )
    ));
  }

}
