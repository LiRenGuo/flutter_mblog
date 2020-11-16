import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/follow_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/home_detail_page.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/util/build_content.dart';
import 'package:flutter_mblog/util/image_process_tools.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:flutter_mblog/widget/four_square_grid_image.dart';
import 'package:flutter_mblog/widget/retweet_widget.dart';
import 'package:flutter_mblog/widget/url_web_widget.dart';

class PostDetailCard extends StatefulWidget {
  final PostItem item;
  const PostDetailCard({Key key, this.item}) : super(key: key);
  @override
  _PostDetailCardState createState() => _PostDetailCardState();
}

class _PostDetailCardState extends State<PostDetailCard> {
  bool isAttention;
  bool isOkAttention = false;
  UserModel userModel;

  @override
  void initState() {
    initAttention();
    super.initState();
  }

  initAttention() async {
    userModel = await Shared_pre.Shared_getUser();
    FollowModel followModel =  await UserDao.getFollowingList(userModel.id,context);
    bool isAtt = false;
    if (followModel != null && followModel.followList.length != 0) {
      followModel.followList.forEach((element) {
        if (element.id == widget.item.user.id) {
          isAtt = true;
        }
      });
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
        isAttention = true;
      });
    }
  }

  _unfollowYou(String userId){
    print(userId);
    FollowDao.unfollow(userId, context);
    Navigator.pop(context);
    if (mounted) {
      setState(() {
        isAttention = false;
      });
    }
  }

  void _atToDetail(String name,BuildContext context)async{
    String id =  await UserDao.getIdByName(name,context);
    print("根据用户名查出来的ID >>>> $id");
    Navigator.push(context, MaterialPageRoute(builder: (context) => MinePage(userid: id,wLoginUserId: userModel.id,)));
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
          children: <Widget>[
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    child: ClipOval(
                      child: ImageProcessTools.CachedNetworkProcessImage(widget.item.user.avatar,memCacheWidth: 450,memCacheHeight: 450),
                    ),
                    width: AdaptiveTools.setRpx(90),
                    height: AdaptiveTools.setRpx(90),
                  ),
                 Expanded(
                   child:  Padding(
                     padding: EdgeInsets.only(left: 10),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: <Widget>[
                         Container(
                           child: Text(widget.item.user.name,
                             style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),overflow: TextOverflow.ellipsis,),
                         ),
                         Container(
                           child: Text(
                             "@ ${widget.item.user.username}",style: TextStyle(color: Colors.black54),
                           ),
                           margin: EdgeInsets.only(top: 5),
                         )
                       ],
                     ),
                   ),
                 ),
                  InkWell(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Icon(Icons.keyboard_arrow_down,color: Colors.black54,),
                    ),
                    onTap: (){
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
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: ListView(
                                  children: <Widget>[
                                    isOkAttention ?
                                    ListTile(
                                      leading: Container(
                                        child: isAttention?Image.asset("images/unattention.png"):Image.asset("images/attention.png"),
                                        padding: EdgeInsets.all(14),
                                      ),
                                      title: isAttention ?Text("取消关注 @${widget.item.user.name}",style: TextStyle(fontSize: 15),):Text("关注 @${widget.item.user.name}",style: TextStyle(fontSize: 15),),
                                      onTap: (){
                                        isAttention?_unfollowYou(widget.item.user.id):_followYou(widget.item.user.id);
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
            ),
            Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: _content(context),
                ),
                if (widget.item.photos.length != 0) FourSquareGridImage.buildImage(context, widget.item.photos),
                if (widget.item.postId != null) widget.item.postId == "*" ? _buildRemoteRetweet(): RetweetWidget(widget.item.user.avatar, widget.item.user.name, widget.item.user.username
                , widget.item.forwardPost.id, widget.item.forwardPost.ctime.toString()
                , widget.item.forwardPost.content, widget.item.forwardPost.photos),
                SizedBox(height: 5,),
                if (widget.item.website != null) UrlWebWidget(widget.item.website),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Row(
                    children: <Widget>[
                      Text(TimeUtil.parse(widget.item.ctime.toString()),
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text('来自 ${widget.item.devicemodel}',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        )
    );
  }

  _content(BuildContext context) {
    String content = widget.item.content;
    return BuildContent.buildContent(content,context,atOnTap: (name) => _atToDetail(name, context));
  }

  Widget _buildRemoteRetweet() {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(Icons.error,size: 14,color: Colors.red,),
          Text("原帖已删除",)
        ],
      ),
    );
  }
}
