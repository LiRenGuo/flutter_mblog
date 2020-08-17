import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/widget/post_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  List<PostItem> items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Container(
          padding: EdgeInsets.all(5),
          child: CircleAvatar(
            radius: 36,
            backgroundImage: NetworkImage('http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLYicLia9bCyRQhpCG3ofQ4dQhouIRlvnTv3DCox8v0sj9Tk01TmD3xPZTjFLxmARgEKy27T0RSC6UA/132'),
          ),
        ),
        title: Text(
          '主页',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => _item(items[index]),
        ),
      ),
      backgroundColor: Color(0xfff5f5f5),
    );
  }

  _item(PostItem item) {
    return Container(
      child: PostCard(item: item),
    );
  }

  _loadData() async {
    PostModel postModel = await PostDao.getList(page);
    setState(() {
      items = postModel.resultList;
    });
  }
}
