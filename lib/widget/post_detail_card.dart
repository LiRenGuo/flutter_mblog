import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/pages/my_page.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';

class PostDetailCard extends StatelessWidget {
  final PostItem item;

  const PostDetailCard({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
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
                  child: _content(context),
                ),
                if (item.photos.length != 0) _photoItem(),
              ],
            ),
          ],
        )
    );
  }

  List<Widget> _buildList() {
    return item.photos.map((img) => _item(img)).toList();
  }

  Widget _item(String img) {
    return Container(
      child: Image.network(
        img,
        fit: BoxFit.cover,
      ),
    );
  }

  _photoItem() {
    if (item.photos.length == 1) {
      return Container(
        height: 200,
        margin: EdgeInsets.only(top: 10),
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Image.network(
            item.photos[0],
            fit: BoxFit.cover,
            height: 200,
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
            children: _buildList()),
      );
    }
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
}
