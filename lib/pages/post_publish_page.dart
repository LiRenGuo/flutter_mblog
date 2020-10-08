import 'dart:io';
import 'dart:typed_data';

import 'package:date_format/date_format.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/navigator/tab_navigator.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/util/image_process_tools.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/widget/four_square_grid_image.dart';
import 'package:flutter_mblog/widget/loading_container.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class PostPublishPage extends StatefulWidget {
  final String avatar;
  final PostItem postItem;
  final String postId;

  const PostPublishPage({Key key, this.avatar, this.postItem,this.postId})
      : super(key: key);

  @override
  _PostPublishPageState createState() => _PostPublishPageState();
}

class _PostPublishPageState extends State<PostPublishPage> {
  PostItem postItem;
  String devicemodel;
  FocusNode _commentFocus = FocusNode();
  TextEditingController _contentController = TextEditingController();
  List<Asset> fileList = List<Asset>();
  File selectedImageFile;
  bool _loading = false;
  bool isOkForPostItem = false;

  @override
  void initState() {
    getDeviceInfo();
    initPostItem();
    super.initState();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  initPostItem()async{
    if (widget.postId != null) {
      postItem =  await PostDao.getPostById(widget.postId,context);
    }
    if(widget.postItem != null){
      postItem = widget.postItem;
    }
    if (mounted) {
      setState(() {
        isOkForPostItem = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Colors.white,
        leading: GestureDetector(
          child: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
              FocusScope.of(context).requestFocus(FocusNode()); //收起键盘
            },
          ),
        ),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () {
                _onPublish(context);
              },
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                  child: Text('发送',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ),
            ),
          )
        ],
      ),
      body: isOkForPostItem ? _publishContent():Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  // 发布内容页面
  _publishContent() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    _buildTextContent(),
                    fileList.length == 0 ? Container() : _buildGridImage(),
                    postItem != null ? _buildRetweetCard() : Container()
                  ],
                ),
                Positioned(
                  child: LoadingContainer(isLoading: _loading, child: Container()),
                ),
              ],
            ),
          ),
          _buildBottom(),
        ],
      ),
    );
  }

  // 构建转推卡片
  _buildRetweetCard() {
    return Padding(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    child: ClipRRect(
                      child: ImageProcessTools.CachedNetworkProcessImage(widget.avatar,memCacheHeight: 250,memCacheWidth: 250),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    width: AdaptiveTools.setRpx(60),
                    height: AdaptiveTools.setRpx(60),
                  ),
                  Container(
                    child: Text(postItem.user.name),
                    margin: EdgeInsets.only(left: 10),
                  ),
                  Container(
                    child: Text(
                      "@${postItem.user.username}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black38),
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: Text(
                      '${TimeUtil.parse(postItem.ctime.toString())}',
                      style: TextStyle(color: Colors.black38),
                    ),
                  )
                ],
              ),
              padding: EdgeInsets.fromLTRB(15, 5, 5, 5),
            ),
            Container(
              child: Text("${postItem.content}"),
              padding: EdgeInsets.fromLTRB(15, 5, 5, 5),
            ),
            postItem.photos != null && postItem.photos.length != 0
                ? FourSquareGridImage.buildRetweetImage(postItem.photos)
                : Container(),
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 5, 20, 20),
    );
  }

  //底部操作栏布局
  _buildBottom() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Color(0xffF9F9F9),
        padding: EdgeInsets.only(left: 15, right: 5, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBottomIcon("images/icon_image.webp", () => _loadAssets()),
            _buildBottomIcon("images/icon_mention.png", () => print('@联系人')),
            _buildBottomIcon("images/icon_topic.png", () => print("topic..")),
            _buildBottomIcon("images/icon_gif.png", () => print("")),
            _buildBottomIcon(
                "images/icon_emotion.png", () => _loadEmojiPicker()),
            _buildBottomIcon("images/icon_add.png", () => print("")),
          ],
        ),
      ),
    );
  }

  _loadEmojiPicker() async {
    EmojiPicker(
      rows: 3,
      columns: 7,
      recommendKeywords: ["racing", "horse"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        print(emoji);
      },
    );
  }

  // 打开系统相册
  Future<void> _loadAssets() async {
    FocusScope.of(context).requestFocus(_commentFocus); //获取输入框的焦点
    _commentFocus.unfocus(); //让输入框失焦 使再次点击使会出现输入框
    List<Asset> resultList = fileList;
    try {
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: fileList,
        maxImages: 4, //最多9张
        enableCamera: true,
      );
    } catch (e) {
      print(e.toString());
    }
    if (mounted) {
      setState(() {
        fileList = resultList;
      });
    }
  }

  //已选择图片的九宫格显示
  _buildGridImage() {
    int gridCount;
    if (fileList.length == 0) {
      gridCount = 0;
    } else if (fileList.length > 0 && fileList.length < 9) {
      gridCount = fileList.length + 1;
    } else {
      gridCount = fileList.length;
    }

    return Padding(
      child: GridView.count(
        shrinkWrap: true,
        primary: false,
        crossAxisCount: 3,
        children: List.generate(gridCount, (index) {
          // 这个方法用于生成GridView中的一个item
          var content;
          if (index == fileList.length) {
            // 添加图片按钮
            var addCell = Center(
              child: Image.asset(
                'images/mine_feedback_add_image.png',
                width: 300,
                height: 300,
              ),
            );
            content = GestureDetector(
              onTap: () {
                // 如果已添加了4张图片，则提示不允许添加更多
                if (fileList.length > 9) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('最多只能添加4张图片'),
                  ));
                  return;
                }
                _loadAssets();
              },
              child: addCell,
            );
          } else {
            content = Stack(
              children: <Widget>[
                Center(
                    child: AssetThumb(
                        width: 300, height: 300, asset: fileList[index])),
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      fileList.removeAt(index);
                      setState(() {});
                    },
                    child: Image.asset(
                      'images/mine_feedback_ic_del.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                )
              ],
            );
          }
          return Container(
            margin: EdgeInsets.all(10),
            width: 80,
            height: 80,
            color: Colors.white,
            child: content,
          );
        }),
      ),
      padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
    );
  }

  //发送的文本内容
  _buildTextContent() {
    return ListTile(
      leading: ClipRRect(
        child: ImageProcessTools.CachedNetworkProcessImage(widget.avatar,memCacheHeight: 250,memCacheWidth: 250),
        borderRadius: BorderRadius.circular(50),
      ),
      title: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              focusNode: _commentFocus,
              autofocus: true,
              maxLength: 200,
              decoration: InputDecoration(
                  hintText: '分享新鲜事...', border: InputBorder.none),
              style: TextStyle(fontSize: 16),
              minLines: 1,
              maxLines: 100,
              controller: _contentController,
            ),
          ),
        ],
      ),
    );
  }

  //底部栏图标
  _buildBottomIcon(String icon, onTap) {
    return Container(
      child: InkWell(
        onTap: onTap,
        child: Image.asset(
          icon,
          width: 25,
          height: 25,
        ),
      ),
    );
  }

  _onPublish(BuildContext context) {
    final String content = _contentController.text.trim();
    if (content.length <= 0) {
      MyToast.show('请输入您的新鲜事~');
      return;
    }
    if (content.length <= 2) {
      MyToast.show('新鲜事不能少于2个字');
      return;
    }
    try {
      FormData formData = FormData();
      setState(() {
        _loading = true;
      });
      formData.fields.add(MapEntry("content", content));
      print("设备型号：$devicemodel");
      print("设备内容：$content");
      formData.fields.add(MapEntry("devicemodel", devicemodel));
      if (fileList.length > 0) {
        Iterable.generate(fileList.length).forEach((index) async {
          Asset image = fileList[index];
          ByteData byteData = await image.getByteData();
          List<int> imageData = byteData.buffer.asUint8List();
          String name = "$index.jpg";
          MultipartFile multipartFile = MultipartFile.fromBytes(
            imageData,
            filename: name,
          );
          MapEntry<String, MultipartFile> file =
              MapEntry("files", multipartFile);
          formData.files.add(file);
          if (formData.files.length == fileList.length) {
            _publishApi(context, formData);
          }
        });
      } else {
        _publishApi(context, formData);
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  _publishApi(BuildContext context, FormData formData) async {
    //发布帖子
    print("发布帖子");
    if (postItem != null && postItem.id != null) {
      print("我是转发啊");
      formData.fields.add(MapEntry("postId",postItem.id));
      await PostDao.retweetPublish(context, formData);
    }else{
      await PostDao.publish(context, formData);
    }
    setState(() {
      _loading = false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (content) => TabNavigator()));
  }

  Future getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      devicemodel = "Android";
      print(androidInfo.toString());
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      devicemodel = iosInfo.name;
    }
  }
}
