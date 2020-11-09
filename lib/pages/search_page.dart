import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:flutter_mblog/widget/post_card.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<PostItem> postItemList = [];
  TextEditingController searchController = new TextEditingController();
  ScrollController _controller = new ScrollController();

  String searchContent;
  UserModel userModel;

  bool isok = false;
  bool autofocus = true;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchController.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        _getPostModel(searchContent,loadMore: true);
      }
    });
  }

  _getPostModel(String keyword,{bool loadMore = false}) async {
    PostModel postModel = await PostDao.findByKeyword(searchContent,context);
    userModel = await Shared_pre.Shared_getUser();
    if (mounted) {
      setState(() {
        if (!loadMore) {
          postItemList = postModel.content;
        }else{
          postItemList.addAll(postModel.content);
        }
        isok = true;
        autofocus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.blue),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Container(
            child: TextField(
              controller: searchController,
              style: TextStyle(fontSize: 16.0, color: Colors.black),
              onChanged: (value) {
                setState(() {
                  searchContent = value;
                  if(value == "") {
                    postItemList = [];
                  }else{
                    _getPostModel(searchContent);
                  }
                });
              },
              autofocus: autofocus,
              decoration: InputDecoration(
                  hintText: "请输入关键字",
                  icon: InkWell(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  suffixIcon: searchContent == null || searchContent == ""
                      ? Container(
                          width: 0,
                          height: 0,
                        )
                      : InkWell(
                          child: Container(
                            child: Icon(Icons.clear),
                            margin:
                                EdgeInsets.only(top: AdaptiveTools.setRpx(4)),
                          ),
                          onTap: () {
                            setState(() {
                              searchController.text = "";
                              searchContent = "";
                            });
                          },
                        ),
                  hintStyle: TextStyle(fontSize: 16),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue))),
            ),
          ),
        ),
        body: Container(
          child: isok && postItemList.length != 0
              ? EasyRefresh(
                  header: MaterialHeader(),
                  child: ListView.builder(
                    controller: _controller,
                      itemCount: postItemList.length,
                      itemBuilder: (context, index) => PostCard(
                            item: postItemList[index],
                            index: index,
                            userId: userModel.id,
                            avatar: userModel.avatar,
                          )),
                  onRefresh: _onRefresh,
                )
              : Container(
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.only(top: 100),
                  child: searchContent != null && searchContent != ""
                      ? Text("""未找到与 "$searchContent" 相关的内容""")
                      : Container(),
                ),
        ),
      ),
    );
  }

  // 上拉刷新
  Future<void> _onRefresh() async {
    isok = false;
    setState(() {
      _getPostModel(searchContent);
    });
  }
}
