import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/pages/home_detail_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';

import 'four_square_grid_image.dart';

// ignore: must_be_immutable
class RetweetWidget extends StatefulWidget {
  final String avatar;
  final String name;
  final String username;

  final String postItemId;
  final String postItemCtime;
  final String content;
  final List<String> photos;

  RetweetWidget(this.avatar,this.name,this.username,this.postItemId,this.postItemCtime,this.content,this.photos);

  @override
  _RetweetWidgetState createState() => _RetweetWidgetState();
}

class _RetweetWidgetState extends State<RetweetWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(top: 3),
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: AdaptiveTools.setRpx(8)),
                    child: ClipOval(
                      child: Image.network(
                        widget.avatar,
                        cacheHeight: 450,
                        cacheWidth: 450,
                      ),
                    ),
                    width: AdaptiveTools.setRpx(50),
                    height: AdaptiveTools.setRpx(50),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(widget.name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                  ),
                  Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Text(
                          "@${widget.username}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey,fontSize: 12),
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(right: 5),
                    child: Text(
                      "${TimeUtil.parse(widget.postItemCtime)}",
                      style:
                      TextStyle(fontSize: 13, color: Colors.black38),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 3, 3),
              child: Text("${widget.content}"),
            ),
            // TODO
            widget.photos != null && widget.photos.length != 0
                ? FourSquareGridImage.buildRetweetImage(widget.photos)
                : Container()
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomeDetailPage(
              new PostItem(),
              postId: widget.postItemId,
            )));
      },
    );
  }

}
