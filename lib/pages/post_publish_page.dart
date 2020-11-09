import 'dart:io';
import 'dart:typed_data';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mblog/dao/post_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/follow_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/navigator/tab_navigator.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/TimeUtil.dart';
import 'package:flutter_mblog/util/image_process_tools.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:flutter_mblog/widget/four_square_grid_image.dart';
import 'package:flutter_mblog/widget/loading_container.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PostPublishPage extends StatefulWidget {
  final String avatar;
  final PostItem postItem;
  final String postId;

  const PostPublishPage({Key key, this.avatar, this.postItem, this.postId})
      : super(key: key);

  @override
  _PostPublishPageState createState() => _PostPublishPageState();
}

class _PostPublishPageState extends State<PostPublishPage> {
  FollowModel followModel;

  PostItem postItem;
  String devicemodel;
  FocusNode _commentFocus = FocusNode();

  List<String> typeList = [];
  List<Asset> fileList = List<Asset>();
  List<String> gifList = List();

  List<dynamic> fileGifList = [];

  File selectedImageFile;
  bool _loading = false;
  bool isOkForPostItem = false;

  String content = "";
  String contenting = "";
  bool deleteAT = false;

  final GlobalKey<FormState> _urlWebKey = new GlobalKey<FormState>();
  TextEditingController _urlWebController = new TextEditingController();
  WebViewController _webViewController;
  String _urlWeb = "";
  String _title = "";

  TextEditingController _contentTextEditingController = new TextEditingController();

  @override
  void initState() {
    getDeviceInfo();
    initPostItem();
    _commentFocus.addListener(() {
      print("Has focus: ${_commentFocus.hasFocus}");
      print("_commentFocus.onKey ${_commentFocus}");
    });
    super.initState();
  }

  @override
  void dispose() {
    _commentFocus.dispose();
    _contentTextEditingController.dispose();
    _urlWebController.dispose();
    super.dispose();
  }

  initPostItem() async {
    UserModel userModel = await Shared_pre.Shared_getUser();
    followModel = await UserDao.getFollowingList(userModel.id, context);
    if (widget.postId != null) {
      postItem = await PostDao.getPostById(widget.postId, context);
    }
    if (widget.postItem != null) {
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
      resizeToAvoidBottomPadding: false,
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
      body: isOkForPostItem
          ? _publishContent()
          : Container(
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
                Column(
                  children: [
                    _buildTextContent(),
                    fileGifList.length == 0 ? Container() : _buildGridImage(),
                    postItem != null ? _buildRetweetCard() : Container(),
                    _urlWeb != null && _urlWeb != ""
                        ? _buildWebView()
                        : Container()
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
                    margin: EdgeInsets.only(top: AdaptiveTools.setRpx(10)),
                    child: ClipRRect(
                      child: ImageProcessTools.CachedNetworkProcessImage(
                          widget.avatar,
                          memCacheHeight: 250,
                          memCacheWidth: 250),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    width: AdaptiveTools.setRpx(60),
                    height: AdaptiveTools.setRpx(60),
                  ),
                  Container(
                    child: Text(postItem.user.name),
                    margin: EdgeInsets.only(left: 10),
                  ),
                  Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(5, 9, 0, 10),
                        child: Text(
                          "@${postItem.user.username}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black38),
                        ),
                      )),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                    child: Text(
                      "${TimeUtil.parse(postItem.ctime.toString())}",
                      style:
                      TextStyle(fontSize: 13, color: Colors.black38),
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

  /// 构建网页预览图
  _buildWebView() {
    return Padding(
      child: Container(
        child: Column(
          children: [
            Container(
              height: AdaptiveTools.setRpx(400),
              child: Stack(
                children: [
                  Container(
                    child: WebView(
                      initialUrl: _urlWeb,
                      onWebViewCreated: (controller) {
                        _webViewController = controller;
                      },
                      onPageFinished: (url) {
                        _webViewController.evaluateJavascript("document.title").then((result) {
                          setState(() {
                            _title = result;
                          });
                        });
                      },
                      navigationDelegate: (NavigationRequest request) {
                        print("request.url >> ${request.url}");
                        if (request.url.startsWith("http") ||
                            request.url.startsWith("https")) {
                          print("允许请求");
                          return NavigationDecision.navigate;
                        }
                        return NavigationDecision.prevent;
                      },
                      javascriptMode: JavascriptMode.unrestricted,
                    ),
                    height: AdaptiveTools.setRpx(300),
                  ),
                  InkWell(
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_title),
                          Text("$_urlWeb")
                        ],
                      ),
                      padding: EdgeInsets.only(top: AdaptiveTools.setRpx(310),left: AdaptiveTools.setRpx(20)),
                    ),
                    onTap: () {
                      print("111");
                    },
                  ),
                  InkWell(
                    child: Container(
                      alignment: Alignment.topRight,
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.remove_circle,color: Colors.red,),
                    ),
                    onTap: (){
                      setState(() {
                        _title = "";
                        _urlWeb = "";
                      });
                    },
                  ),
                ],
              ),
            )
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
            _buildBottomIcon("images/icon_mention.png", () => _loadAtUser()),
            _buildBottomIcon("images/icon_url.png", () => _addUrl()),
            Container(
              child: InkWell(
                child: Image.asset(
                  "images/icon_gif.png",
                  width: 25,
                  height: 25,
                ),
                onTap: () async {
                  final gif = await GiphyPicker.pickGif(
                    context: context,
                    apiKey: 'C8AXTOIfAiAtIjMaCBjSC8T4UkKRnqcT',
                    fullScreenDialog: false,
                    previewType: GiphyPreviewType.previewWebp,
                    decorator: GiphyDecorator(
                      showAppBar: false,
                      searchElevation: 4,
                      giphyTheme: ThemeData.dark().copyWith(
                        inputDecorationTheme: InputDecorationTheme(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  );
                  if (gif != null) {
                    setState(() {
                      fileGifList.add("https://media2.giphy.com/media/" +
                          gif.id +
                          "/giphy.gif");
                    });
                  }
                },
              ),
            ),
            _buildBottomIcon(
                "images/icon_emotion.png",
                () => showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            color: Colors.white),
                        height: AdaptiveTools.setRpx(460),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Text("  "),
                              width: AdaptiveTools.setRpx(60),
                              height: AdaptiveTools.setRpx(10),
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                            ),
                            Spacer(),
                            Container(
                              child: buildSticker(),
                            ),
                          ],
                        ),
                      );
                    })),
            _buildBottomIcon("images/icon_add.png", () => print("")),
          ],
        ),
      ),
    );
  }

  _loadAtUser({bool isShow = false}) async {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: Colors.white),
            height: AdaptiveTools.setRpx(600),
            child: Column(
              children: <Widget>[
                Container(
                  child: Text("  "),
                  width: AdaptiveTools.setRpx(60),
                  height: AdaptiveTools.setRpx(10),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: followModel.followList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            isShow
                                ? _contentTextEditingController.text +=
                                    "${followModel.followList[index].username} "
                                : _contentTextEditingController.text +=
                                    "@${followModel.followList[index].username} ";
                            setState(() {
                              content += isShow
                                  ? "${followModel.followList[index].username} "
                                  : "@${followModel.followList[index].username} ";
                            });
                          },
                          leading: Container(
                            width: 40,
                            height: 40,
                            child: ClipOval(
                              child:
                                  ImageProcessTools.CachedNetworkProcessImage(
                                      followModel.followList[index].avatar,
                                      memCacheHeight: 450,
                                      memCacheWidth: 450),
                            ),
                          ),
                          title: Text(followModel.followList[index].name),
                          subtitle: Text(
                              "@${followModel.followList[index].username}"),
                        );
                      }),
                )
              ],
            ),
          );
        });
  }

  _addUrl() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('输入链向网址'),
            content: Container(
              child: Column(
                children: <Widget>[
                  Form(
                    child: TextFormField(
                      controller: _urlWebController,
                      decoration: InputDecoration(
                          hintText: 'http://或者https://',
                          filled: true,
                          fillColor: Colors.grey.shade50),
                      validator: (value) {
                        RegExp url = new RegExp(r"^((https|http)?:\/\/)[^\s]+");
                        var result = url.firstMatch(value);
                        if (result != null) {
                          return null;
                        }
                        return "网址不正确";
                      },
                    ),
                    key: _urlWebKey,
                  ),
                ],
              ),
              height: AdaptiveTools.setRpx(140),
            ),
            actions: <Widget>[
              RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('取消'),
              ),
              RaisedButton(
                onPressed: () {
                  if (_urlWebKey.currentState.validate()) {
                    String url = _urlWebController.text.trim();
                    setState(() {
                      _urlWeb = url;
                      _urlWebController.text = "";
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('确定'),
              ),
            ],
          );
        });
  }

  // 构建emoji图像
  Widget buildSticker() {
    return EmojiPicker(
      rows: 3,
      columns: 7,
      buttonMode: ButtonMode.MATERIAL,
      recommendKeywords: ["racing", "horse"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        setState(() {
          _contentTextEditingController.text =
              _contentTextEditingController.text + emoji.emoji;
        });
        Navigator.pop(context);
      },
    );
  }

  // 打开系统相册
  Future<void> _loadAssets() async {
    fileList = [];
    gifList = [];
    fileGifList.forEach((element) {
      if (element is Asset)
        fileList.add(element);
      else
        gifList.add(element);
    });
    FocusScope.of(context).requestFocus(_commentFocus); //获取输入框的焦点
    _commentFocus.unfocus(); //让输入框失焦 使再次点击使会出现输入框
    List<Asset> resultList = fileList;
    try {
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: fileList,
        maxImages: 4 - gifList.length, //最多9张
        enableCamera: true,
      );
    } catch (e) {
      print(e.toString());
    }
    if (mounted) {
      setState(() {
        fileList.forEach((element) {
          fileGifList.remove(element);
        });
        print(fileGifList);
        fileGifList.addAll(resultList);
      });
    }
  }

  //已选择图片的九宫格显示
  _buildGridImage() {
    print(fileGifList);
    int gridCount;
    if (fileGifList.length == 0) {
      gridCount = 0;
    } else if (fileGifList.length > 0 && fileGifList.length < 4) {
      gridCount = fileGifList.length + 1;
    } else {
      gridCount = fileGifList.length;
    }
    List<Widget> items = List.generate(gridCount, (index) {
      // 这个方法用于生成GridView中的一个item
      var content;
      if (index == fileGifList.length) {
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
            if (fileGifList.length > 4) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('最多只能添加4张图片或者动图'),
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
                child: fileGifList[index] is String
                    ? Image.network(fileGifList[index])
                    : AssetThumb(
                        width: 300, height: 300, asset: fileGifList[index])),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  fileGifList.removeAt(index);
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
        width: 100,
        height: 100,
        color: Colors.white,
        child: content,
        key: ValueKey(content),
      );
    });
    return Container(
      child: ReorderableListView(
        children: items,
        scrollDirection: Axis.horizontal,
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          dynamic newWidget = fileGifList[oldIndex];
          fileGifList.removeAt(oldIndex);
          fileGifList.insert(newIndex, newWidget);
          var child = items.removeAt(oldIndex);
          items.insert(newIndex, child);
          setState(() {});
        },
      ),
      height: AdaptiveTools.setRpx(250),
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
    );
  }

  //发送的文本内容
  _buildTextContent() {
    return ListTile(
      leading: ClipRRect(
        child: ImageProcessTools.CachedNetworkProcessImage(widget.avatar,
            memCacheHeight: 250, memCacheWidth: 250),
        borderRadius: BorderRadius.circular(50),
      ),
      title: Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            focusNode: _commentFocus,
            autofocus: true,
            maxLength: 200,
            decoration:
                InputDecoration(hintText: '分享新鲜事...', border: InputBorder.none),
            style: TextStyle(fontSize: 16),
            minLines: 1,
            maxLines: 100,
            controller: _contentTextEditingController,
            onChanged: (value) {
              if (content != null && content.length != 0) {
                if (content.length < value.length) {
                  if (value.endsWith("@")) {
                    _loadAtUser(isShow: true);
                  }
                }
              } else {
                if (value.endsWith("@")) {
                  _loadAtUser(isShow: true);
                }
              }
              setState(() {
                content = value;
                contenting = value;
              });
            },
          )),
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
    final String content = _contentTextEditingController.text.trimLeft();
    if (content.length <= 0) {
      MyToast.show('请输入您的新鲜事~');
      return;
    }
    if (content.length <= 3) {
      MyToast.show('新鲜事不能少于3个字');
      return;
    }
    try {
      FormData formData = FormData();
      setState(() {
        _loading = true;
      });
      if(_urlWeb != ""){
        formData.fields.add(MapEntry("website", _urlWeb));
      }
      formData.fields.add(MapEntry("content", content));
      print("设备型号：$devicemodel");
      print("设备内容：$content");
      formData.fields.add(MapEntry("devicemodel", devicemodel));
      if (fileGifList.length > 0) {
        int flag = 0;
        Iterable.generate(fileGifList.length).forEach((index) async {
          dynamic result = fileGifList[index];
          if (result is Asset) {
            flag++;
            Asset image = result;
            ByteData byteData = await image.getByteData();
            List<int> imageData = byteData.buffer.asUint8List();
            String name = "$index.jpg";
            MultipartFile multipartFile = MultipartFile.fromBytes(
              imageData,
              filename: name,
            );
            MapEntry<String, MultipartFile> file =
                MapEntry("files[$index]", multipartFile);
            formData.files.add(file);
          }
          if (result is String) {
            flag++;
            formData.fields.add(MapEntry("files[$index]", result));
          }
          print("formData >>> ${formData.fields.toString()}");
          print("formData >>> ${formData.files.toString()}");
          print("flag == fileGifList.length >>> ${flag}");
          print("flag == fileGifList.length >>> ${fileGifList.length}");

          if (flag == fileGifList.length) {
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
    if (postItem != null && postItem.id != null) {
      formData.fields.add(MapEntry("postId", postItem.id));
      await PostDao.retweetPublish(context, formData);
    } else {
      await PostDao.publish(context, formData);
    }
    setState(() {
      _loading = false;
    });
    Navigator.pop(context);
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
