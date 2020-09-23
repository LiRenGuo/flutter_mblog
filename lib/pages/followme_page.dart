import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/follow_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';

class FollowMePage extends StatefulWidget {
  String userId;
  FollowModel followMeModel;

  FollowMePage({this.userId,this.followMeModel});
  @override
  _FollowMePageState createState() => _FollowMePageState();
}

class _FollowMePageState extends State<FollowMePage> {

  FollowModel _followMeModel;

  Future<Null> _onRefresh() async {
    setState(() {
      _refresh();
    });
  }

  _refresh()async{
    FollowModel newFollowMeModel =  await UserDao.getFollowersList(widget.userId,context);
    if (newFollowMeModel != null) {
      setState(() {
        _followMeModel = newFollowMeModel;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initFollowMeModel();
  }

  initFollowMeModel(){
    _followMeModel = widget.followMeModel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.blue),
          backgroundColor: Colors.white,
          title: Text("关注者",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: _followMeModel != null &&
            _followMeModel.followList.length != 0
            ? Container(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
                itemCount: _followMeModel.followList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      followingUserWidget(
                          _followMeModel.followList[index]),
                      Container(
                        height: 1,
                        color: Colors.black12,
                      )
                    ],
                  );
                }),
          ),
        ):Container(
          color: Color(0xffE7ECF0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text("你尚无任何关注者",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text("当有人关注你时，你将会在这里看到他们。",style: TextStyle(color: Colors.black87,fontSize: 12),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _followYou(String userId){
    print(userId);
    FollowDao.follow(userId, context);
    setState(() {
      _refresh();
    });
  }

  _unfollowYou(String userId){
    print(userId);
    FollowDao.unfollow(userId, context);
    setState(() {
      _refresh();
    });
  }

  Widget followingUserWidget(Follow follow) {
    return Padding(
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
                  child:  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Text(follow.name,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16),),
                            margin: EdgeInsets.only(bottom: 3),
                          ),
                          Container(
                            child: Text("@ ${follow.username}"),
                          ),
                        ],
                      ),
                      Container(
                        child: follow.isfollow ?FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          color: Colors.blue,
                          onPressed: (){
                            _unfollowYou(follow.id);
                          },
                          child: Center(
                            child: Text("取消关注",style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white),),
                          ),
                        ):FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          color: Colors.blue,
                          onPressed: (){
                            _followYou(follow.id);
                          },
                          child: Center(
                            child: Text("关注",style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white),),
                          ),
                        ),
                        height: AdaptiveTools.setRpx(55),
                      )
                    ],
                  ),
                  height:  AdaptiveTools.setRpx(70),
                ),
                Container(
                  child: Text(
                    follow.intro != null && follow.intro != "" ? follow.intro : "这个人很懒什么都没留下",
                    maxLines: 2,overflow: TextOverflow.ellipsis,),
                )
              ],
            ),
          )
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }
}
