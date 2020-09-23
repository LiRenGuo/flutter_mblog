import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/follow_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/home_detail_page.dart';
import 'package:flutter_mblog/pages/my_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:flutter_mblog/widget/fade_route.dart';
import 'package:flutter_mblog/widget/image_all_screen_look.dart';

class PostDetailCard extends StatefulWidget {
  final PostItem item;
  const PostDetailCard({Key key, this.item}) : super(key: key);
  @override
  _PostDetailCardState createState() => _PostDetailCardState();
}

class _PostDetailCardState extends State<PostDetailCard> {
  bool isAttention;
  bool isOkAttention = false;


  @override
  void initState() {
    initAttention();
    super.initState();
  }

  initAttention() async {
    UserModel userModel = await Shared_pre.Shared_getUser();
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.item.user.avatar),
                        radius: 28,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(widget.item.user.name,
                                style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16)),
                            Container(
                              child: Text(
                                "@ ${widget.item.user.username}",style: TextStyle(color: Colors.black54),
                              ),
                              margin: EdgeInsets.only(top: 5),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
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
                if (widget.item.photos.length != 0) _buildImage(widget.item.photos),
                if (widget.item.postId != null) _buildRetweet(widget.item.forwardPost),
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

  Widget _buildRetweet(PostItem postItem) {
    Widget retweetWidget;
    postItem != null && postItem.id != null
        ? retweetWidget = InkWell(
      child: Container(
        margin: EdgeInsets.only(top: 10),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(postItem.user.avatar),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 8, 0, 10),
                        child: Text("${postItem.user.name}"),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 7, 10, 10),
                        child: Text("@${postItem.user.username}",style: TextStyle(color: Colors.black38),),
                      )
                    ],
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 6, 10, 10),
                    child: Text(
                      "${TimeUtil.parse(postItem.ctime.toString())}",
                      style:
                      TextStyle(fontSize: 13, color: Colors.black38),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 3, 3),
              child: Text("${postItem.content}"),
            ),
            postItem.photos != null && postItem.photos.length != 0
                ? _buildRetweetImage(postItem.photos)
                : Container()
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomeDetailPage(null,postId: postItem.id,)));
      },
    )
        : retweetWidget = Container(
      width: 0,
      height: 0,
    );
    return retweetWidget;
  }

  _buildRetweetImage(List<String> photosList) {
    Widget widgets;
    switch (photosList.length) {
      case 1:
        widgets = Container(
          height: 130,
          margin: EdgeInsets.only(top: 5),
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              image: DecorationImage(
                  image: NetworkImage(photosList[0]), fit: BoxFit.cover)),
        );
        break;
      case 2:
        widgets = Container(
          height: 130,
          margin: EdgeInsets.only(top: 5),
          width: double.infinity,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(10)),
                      image: DecorationImage(
                          image: NetworkImage(photosList[0]),
                          fit: BoxFit.cover)),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(10)),
                      image: DecorationImage(
                          image: NetworkImage(photosList[1]),
                          fit: BoxFit.cover)),
                ),
              ),
            ],
          ),
        );
        break;
      case 3:
        widgets = Container(
          height: 130,
          margin: EdgeInsets.only(top: 5),
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10)),
                            image: DecorationImage(
                                image: NetworkImage(photosList[0]),
                                fit: BoxFit.cover)),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(photosList[1]),
                                      fit: BoxFit.cover)),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(10)),
                                  image: DecorationImage(
                                      image: NetworkImage(photosList[2]),
                                      fit: BoxFit.cover)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      case 4:
        widgets = Container(
          height: 130,
          margin: EdgeInsets.only(top: 5),
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(photosList[0]),
                                fit: BoxFit.cover)),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(photosList[1]),
                                fit: BoxFit.cover)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10)),
                            image: DecorationImage(
                                image: NetworkImage(photosList[2]),
                                fit: BoxFit.cover)),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10)),
                            image: DecorationImage(
                                image: NetworkImage(photosList[3]),
                                fit: BoxFit.cover)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
        break;
    }
    return widgets;
  }

  _showImage(BuildContext context, int index) {
    Navigator.of(context).push(FadeRoute(
        page: ImageAllScreenLook(
          imgDataArr:widget.item.photos,
          index: index,
        )
    ));
  }

  List<Widget> _buildList(BuildContext context) {
    return Iterable.generate(widget.item.photos.length).map((index) => _item(widget.item.photos[index], index, context)).toList();
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
          child: Center(child: Center(
            child: CircularProgressIndicator(),
          )),
        );
      },
    );
  }

  Widget _buildImage(List<String> photos) {
    Widget imageWidget;
    switch (photos.length) {
      case 1:
        imageWidget = GestureDetector(
          child: Container(
            height: 200,
            width: double.infinity,
            margin: EdgeInsets.only(top: 10),
            child: ClipRRect(
              child: _cachedImage(photos[0]),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onTap: () => _showImage(context, 0),
        );
        break;
      case 2:
        imageWidget = Container(
          height: 200,
          margin: EdgeInsets.only(top: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  child: Container(
                    height: double.infinity,
                    child: ClipRRect(
                      child: _cachedImage(photos[0]),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                    ),
                  ),
                  onTap: () => _showImage(context, 0),
                ),
              ),
              SizedBox(
                width: 3,
              ),
              Expanded(
                child: GestureDetector(
                  child: Container(
                    height: double.infinity,
                    child: ClipRRect(
                      child: _cachedImage(photos[1]),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8)),
                    ),
                  ),
                  onTap: () => _showImage(context, 1),
                ),
              )
            ],
          ),
        );
        break;
      case 3:
        imageWidget = Container(
          height: 200,
          margin: EdgeInsets.only(top: 10),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          child: ClipRRect(
                            child: _cachedImage(photos[0]),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8)),
                          ),
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        onTap: () => _showImage(context, 0),
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: _cachedImage(photos[1]),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context, 1),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: _cachedImage(photos[2]),
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context, 2),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      case 4:
        imageWidget = Container(
          height: 200,
          margin: EdgeInsets.only(top: 10),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: _cachedImage(photos[0]),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context, 0),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: _cachedImage(photos[1]),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context, 1),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: _cachedImage(photos[2]),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context, 2),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: _cachedImage(photos[3]),
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context, 3),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      default:
        imageWidget = Container();
        break;
    }
    return imageWidget;
  }

  _content(BuildContext context) {
    String content = widget.item.content;
    TextStyle contentStyle = TextStyle(color: Colors.black, fontSize: 16);
    return Text(content, style: contentStyle);
  }
}
