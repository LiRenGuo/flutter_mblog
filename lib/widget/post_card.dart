import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';

class PostCard extends StatelessWidget {
  final PostItem item;

  const PostCard({Key key, this.item}) : super(key: key);

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
                      Text(item.user.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Row(
                          children: <Widget>[
                            Text(TimeUtil.parse(item.ctime.toString()), style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text('来自 ${item.devicemodel}', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
          Container(
            child: Text(item.content, style: TextStyle(fontSize: 16)),
          ),
          if(item.photos.length != 0) _photoItem(),
          Divider(
            height: 2.0,
          ),
          Container(
            child: Text('ccccc'),
          )
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
    if(item.photos.length == 1) {
      return Container(
        height: 200,
        margin: EdgeInsets.only(top: 10),
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Image.network(
            item.photos[0],
            fit: BoxFit.fill,
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
            children: _buildList()
        ),
      );
    }
  }

}
