import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/post_model.dart';

class ShareTwitterDataWidget extends InheritedWidget{
  final List<PostItem> data;
  ShareTwitterDataWidget({
    @required this.data,
    Widget child
  }) :super(child: child);

  //定义一个便捷方法，方便子树中的widget获取共享数据
  static ShareTwitterDataWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShareTwitterDataWidget>();
  }

  @override
  bool updateShouldNotify(ShareTwitterDataWidget old) {
    // TODO: implement updateShouldNotify
    return old.data.length != data.length;
  }
}
