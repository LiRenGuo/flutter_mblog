import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/post_publish_page.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:flutter_mblog/widget/loading_container.dart';
import 'package:flutter_mblog/widget/my_drawer.dart';
import 'package:flutter_mblog/widget/post_card.dart';

const PAGE_SIZE = 10;
const DEFAULT_AVATAR = 'https://zzm888.oss-cn-shenzhen.aliyuncs.com/avatar-default.png';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel userModel;
  int page = 0;
  List<PostItem> items = [];

  bool _loading = true;
  bool _hasMore = true;
  bool _isRequesting = false;

  ScrollController  _scrollController = ScrollController();

  @override
  void initState() {
    _loadData();
    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadData(loadMore: true);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => PostPublishPage(avatar: userModel.avatar)
          ));
        },
        child: Image.asset('images/ic_home_compose.png', fit: BoxFit.cover, scale: 3.0),
        backgroundColor: Colors.blue
      ),
      drawer: MyDrawer(userModel: userModel),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Container(
          padding: EdgeInsets.all(5),
          child: FutureBuilder(
            future: _loadLoginUser(),
            builder: (context, snapshot) {
              // 请求已结束
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  // 请求失败，显示错误
                  return _userAvatar(DEFAULT_AVATAR);
                } else {
                  // 请求成功，显示数据
                  return _userAvatar(userModel.avatar);
                }
              } else {
                // 请求未结束，显示loading
                return CircularProgressIndicator();
              }
            }
          ),
        ),
        title: Text(
          '主页',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: LoadingContainer(
        isLoading: _loading,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Container(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: items.length,
              itemBuilder: (context, index) => _item(items[index], index),
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xfff5f5f5),
    );
  }

  _item(PostItem item, int index) {
    return Container(
      child: PostCard(item: item, index: index),
    );
  }

  _loadData({loadMore = false}) async {
    try{
      if(_isRequesting || !_hasMore) return;

      if(loadMore) page++;
      else page = 0;

      _isRequesting = true; // 正在请求中
      _loading = true;
      PostModel postModel = await PostDao.getList(page, PAGE_SIZE);
      _loading = false; //
      if(mounted) {
        List<PostItem> resultList = [];
        if(loadMore) {
          resultList.addAll(items);
        }
        resultList.addAll(postModel.resultList);
        setState(() {
          items = resultList;
          _isRequesting = false;
          _hasMore = page < postModel.totalPages;
        });
      }
    } catch(e) {
      _loading = false;
      print(e);
    }

  }

  Future<Null> _handleRefresh() async {
    _loadData();
  }

  Future _loadLoginUser() async {
    userModel = await Shared_pre.Shared_getUser();
  }

  Widget _userAvatar(String avatar) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.white
            ),
            child: ClipOval(
                child: Image.network(avatar)
            ),
          ),
        );
      },
    );
  }
}
