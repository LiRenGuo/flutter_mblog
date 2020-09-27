import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/follow_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';

class FollowingPage extends StatefulWidget {
  String userId;
  FollowModel followModel;

  FollowingPage({this.userId, this.followModel});

  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  FollowModel _followModel;

  Future<Null> _onRefresh() async {
    setState(() {
      _refresh();
    });
  }

  _refresh() async {
    FollowModel newFollowModel =
        await UserDao.getFollowingList(widget.userId, context);
    if (newFollowModel != null) {
      setState(() {
        _followModel = newFollowModel;
      });
    } else {
      _followModel = null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _followModel = widget.followModel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.blue),
          backgroundColor: Colors.white,
          title: Text(
            "正在关注",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: _followModel != null && _followModel.followList.length != 0
            ? Container(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    cacheExtent: 1.0,
                      itemCount: _followModel.followList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[
                            followingUserWidget(_followModel.followList[index]),
                            Container(
                              height: 1,
                              color: Colors.black12,
                            )
                          ],
                        );
                      }),
                ),
              )
            : InkWell(
                child: Container(
                  color: Color(0xffE7ECF0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Text("你尚无任何正在关注的人",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            "当你关注别人时，你将会在这里看到他们。",
                            style:
                                TextStyle(color: Colors.black87, fontSize: 12),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  _onRefresh();
                },
              ),
      ),
    );
  }

  _unfollowYou(String userId) {
    print(userId);
    FollowDao.unfollow(userId, context);
    setState(() {
      _refresh();
    });
  }

  Widget followingUserWidget(Follow follow) {
    return InkWell(
      child: Padding(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: follow.avatar != null && follow.avatar.isNotEmpty
                  ? CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(follow.avatar),
              )
                  : CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black54,
              ),
              margin: EdgeInsets.only(right: 10),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                follow.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 16),
                              ),
                              margin: EdgeInsets.only(bottom: 3),
                            ),
                            Container(
                              child: Text("@ ${follow.username}"),
                            ),
                          ],
                        ),
                        Container(
                          height: 30,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                            color: Colors.blue,
                            onPressed: () {
                              _unfollowYou(follow.id);
                            },
                            child: Center(
                              child: Text(
                                "取消关注",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          margin: EdgeInsets.only(right: 5,top: 3),
                        )
                      ],
                    ),
                    height: AdaptiveTools.setRpx(80),
                  ),
                  Container(
                    child: Text(
                      follow.intro.isNotEmpty ? follow.intro : "这个人很懒什么都没留下",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => MinePage(userid: follow.id,wLoginUserId: widget.userId,)));
      },
    );
  }
}
