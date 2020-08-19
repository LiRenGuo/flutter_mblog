import 'package:flutter/material.dart';

class PublishContent extends StatefulWidget {
  final String avatar;

  const PublishContent({Key key, this.avatar}) : super(key: key);

  @override
  _PublishContentState createState() => _PublishContentState();
}

class _PublishContentState extends State<PublishContent> {

  FocusNode _commentFocus = FocusNode();
  TextEditingController _content = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.avatar),
            ),
            title: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    focusNode: _commentFocus,
                    autofocus: true,
                    maxLength: 200,
                    decoration: InputDecoration(
                        hintText: '分享新鲜事...',
                        border: InputBorder.none
                    ),
                    style: TextStyle(fontSize: 16),
                    minLines: 1,
                    maxLines: 100,
                    controller: _content,
                  ),
                )
              ],
            ),
          ),
          GridView.count(
            crossAxisCount: 3,
            children: <Widget>[

            ],
          )
        ],
      ),
    );
  }
}
