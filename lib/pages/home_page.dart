import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/pages/post_publish_page.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
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
  bool _loading = true;
  bool _hasMore = true;
  bool _isRequesting = false;
  ScrollController  _scrollController = ScrollController();
  FollowModel followModel;
  FollowModel followersModel;
  bool isOkAttention = false;

  // 数据队列
  List<PostItem> items = [];

  @override
  void initState() {
    _loadData();
    initAttention();
    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadData(loadMore: true);
      }
    });
    super.initState();
  }

  initAttention() async {
    userModel = await Shared_pre.Shared_getUser();
    followersModel = await UserDao.getFollowersList(userModel.id, context);
    followModel =  await UserDao.getFollowingList(userModel.id,context);
    if (followModel != null && followersModel != null) {
      if (mounted) {
        setState(() {
          isOkAttention = true;
        });
      }
    }
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
      drawer: isOkAttention ? MyDrawer(userModel: userModel,followModel: followModel,followersModel: followersModel,) : MyDrawer(userModel: userModel),
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
                  print("错误控制");
                  return _userAvatar(DEFAULT_AVATAR);
                } else {
                  // 请求成功，显示数据
                  return _userAvatar(userModel.avatar);
                }
              } else {
                // 请求未结束，显示loading
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }
          ),
        ),
        title: Container(
          child: Text(
            '主页',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          margin: EdgeInsets.only(bottom: 1),
        ),
      ),
      body: LoadingContainer(
        isLoading: _loading,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Container(
            // 渲染数据队列
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

  // 构建单个对象
  _item(PostItem item, int index) {
      return Container(
        child: PostCard(item: item, index: index, userId: userModel.id,avatar:userModel.avatar),
      );
  }

  // 加载更多数据
  _loadData({loadMore = false}) async {
    try{
      if(_isRequesting || !_hasMore) return;
      if(loadMore) page++;
      else page = 0;
      _isRequesting = true; // 正在请求中
      _loading = true;
      PostModel postModel = await PostDao.getList(page, PAGE_SIZE,context);
      _loading = false; //
      print("首页：mounted = $mounted");
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

  // 上拉刷新
  Future<void> _handleRefresh() async {
    setState(() {
      _loadData();
      initAttention();
    });
  }

  // 加载用户信息
  Future _loadLoginUser() async {
    userModel = await Shared_pre.Shared_getUser();
  }

  // 用户头像
  Widget _userAvatar(String avatar) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.white
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(avatar),
            ),
          ),
        );
      },
    );
  }

}
