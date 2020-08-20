import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/upload_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:image_picker/image_picker.dart';

class EditMinePage extends StatefulWidget {
  @override
  _EditMinePageState createState() => _EditMinePageState();
}

class _EditMinePageState extends State<EditMinePage> {
  var banner;
  var avatar;

  TextEditingController _nameEtController = TextEditingController();
  FocusNode focusNameNode = new FocusNode();
  Color nameColor = Colors.black54;
  double nameSize = 20;

  TextEditingController _introductionEtController = TextEditingController();
  FocusNode focusIntroductionNode = new FocusNode();
  Color introductionColor = Colors.black54;
  double introductionSize = 20;

  TextEditingController _positionEtController = TextEditingController();
  FocusNode focusPositionNode = new FocusNode();
  Color positionColor = Colors.black54;
  double positionSize = 20;

  TextEditingController _urlEtController = TextEditingController();
  FocusNode focusUrlNode = new FocusNode();
  Color urlColor = Colors.black54;
  double urlSize = 20;

  UserModel _userModel;

  getUserInfo() {
    return UserDao.getUserInfo(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusUrlNode.addListener(() {
      setState(() {
        if (focusUrlNode.hasFocus) {
          urlColor = Colors.blue;
          urlSize = 25;
        } else {
          urlColor = Colors.black54;
          urlSize = 20;
        }
      });
    });
    focusIntroductionNode.addListener(() {
      setState(() {
        if (focusIntroductionNode.hasFocus) {
          introductionColor = Colors.blue;
          introductionSize = 25;
        } else {
          introductionColor = Colors.black54;
          introductionSize = 20;
        }
      });
    });
    focusNameNode.addListener(() {
      setState(() {
        if (focusNameNode.hasFocus) {
          nameColor = Colors.blue;
          nameSize = 25;
        } else {
          nameColor = Colors.black54;
          nameSize = 20;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.blue),
          backgroundColor: Colors.white,
          title: Text(
            "编辑个人资料",
            style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  print("----"+_introductionEtController.text);
                  FormData formDate = FormData.fromMap({
                    "id":_userModel.id,
                    "name":_nameEtController.text,
                    "banner": banner,
                    "avatar": avatar,
                    "intro": _introductionEtController.text,
                    "homepage": _urlEtController.text,
                  });
                  UserDao.saveUserInfo(formDate);
                  Navigator.pop(context);
                },
                child: Text(
                  "保存",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        body: FutureBuilder(
          future: getUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(avatar);
              _userModel = snapshot.data;
              _nameEtController.text = _userModel.name;
              _introductionEtController.text = _userModel.intro;
              _urlEtController.text = _userModel.homepage;
              _positionEtController.text = "GuangDong";
              return Container(
                child: ListView(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              height: AdaptiveTools.setPx(140),
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              child: banner != null ? Image.network(banner,fit: BoxFit.cover,):Image.network(
                                _userModel.banner,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              height: AdaptiveTools.setPx(140),
                              padding:
                              EdgeInsets.only(top: AdaptiveTools.setPx(60)),
                              alignment: Alignment.topCenter,
                              color: Colors.black38,
                              child: InkWell(
                                child: Container(
                                  height: AdaptiveTools.setPx(25),
                                  child: Image.asset(
                                    "images/ic_vector_camera_stroke.png",
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  print("选择图片");
                                  showModalBottomSheet(
                                      context: context, builder: (context) {
                                    return Container(
                                      height: AdaptiveTools.setPx(140),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center,
                                        children: <Widget>[
                                          InkWell(
                                            child: Container(
                                              child: Text("拍照", style: TextStyle(
                                                  fontSize: AdaptiveTools.setPx(
                                                      17)),),
                                              margin: EdgeInsets.all(10),
                                            ),
                                            onTap: (){
                                              _takePhoto("banner");
                                              Navigator.pop(context);
                                            },
                                          ),
                                          Container(
                                            height: 1,
                                            color: Colors.black12,
                                          ),
                                          InkWell(
                                            child: Container(
                                              margin: EdgeInsets.all(10),
                                              child: Text("相册",
                                                  style: TextStyle(
                                                      fontSize: AdaptiveTools
                                                          .setPx(17))),
                                            ),
                                            onTap: () {
                                              _openGallery("banner");
                                              Navigator.pop(context);
                                            },
                                          ),
                                          Container(
                                            height: 4,
                                            color: Colors.black12,
                                          ),
                                          InkWell(
                                            child: Container(
                                              margin: EdgeInsets.all(10),
                                              child: Text("取消",
                                                  style: TextStyle(
                                                      fontSize: AdaptiveTools
                                                          .setPx(17))),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Stack(
                          children: <Widget>[
                            Container(
                                margin: EdgeInsets.only(
                                    top: AdaptiveTools.setPx(110)),
                                child: Container(
                                  child: CircleAvatar(
                                      maxRadius: AdaptiveTools.setPx(40),
                                      backgroundImage: avatar != null ?NetworkImage(avatar): NetworkImage(_userModel.avatar)),
                                  margin: EdgeInsets.only(
                                      left: AdaptiveTools.setPx(18),
                                      bottom: AdaptiveTools.setPx(10)),
                                )),
                            Container(
                              height: AdaptiveTools.setPx(80),
                              padding: EdgeInsets.all(AdaptiveTools.setPx(30)),
                              decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(40))),
                              margin: EdgeInsets.only(
                                  top: AdaptiveTools.setPx(110),
                                  left: AdaptiveTools.setPx(18)),
                              child: InkWell(
                                child: Container(
                                  height: AdaptiveTools.setPx(25),
                                  child: Image.asset(
                                    "images/ic_vector_camera_stroke.png",
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  print("修改头像");
                                  showModalBottomSheet(
                                      context: context, builder: (context) {
                                    return Container(
                                      height: AdaptiveTools.setPx(140),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center,
                                        children: <Widget>[
                                          InkWell(
                                            child: Container(
                                              child: Text("拍照", style: TextStyle(
                                                  fontSize: AdaptiveTools.setPx(
                                                      17)),),
                                              margin: EdgeInsets.all(10),
                                            ),
                                            onTap: (){
                                              _takePhoto("avatar");
                                              Navigator.pop(context);
                                            },
                                          ),
                                          Container(
                                            height: 1,
                                            color: Colors.black12,
                                          ),
                                          InkWell(
                                            child: Container(
                                              margin: EdgeInsets.all(10),
                                              child: Text("相册",
                                                  style: TextStyle(
                                                      fontSize: AdaptiveTools
                                                          .setPx(17))),
                                            ),
                                            onTap: () {
                                              _openGallery("avatar");
                                              Navigator.pop(context);
                                            },
                                          ),
                                          Container(
                                            height: 4,
                                            color: Colors.black12,
                                          ),
                                          InkWell(
                                            child: Container(
                                              margin: EdgeInsets.all(10),
                                              child: Text("取消",
                                                  style: TextStyle(
                                                      fontSize: AdaptiveTools
                                                          .setPx(17))),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 10, 20),
                          child: TextField(
                            controller: _nameEtController,
                            focusNode: focusNameNode,
                            style:
                            TextStyle(fontSize: 20.0, color: Colors.black),
                            decoration: InputDecoration(
                                labelText: "用户名",
                                labelStyle: TextStyle(
                                    color: nameColor, fontSize: nameSize),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blue, width: 4)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black54, width: 4))),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 10, 20),
                          child: TextField(
                            maxLines: 3,
                            controller: _introductionEtController,
                            focusNode: focusIntroductionNode,
                            style:
                            TextStyle(fontSize: 20.0, color: Colors.black),
                            decoration: InputDecoration(
                                labelText: "简介",
                                labelStyle: TextStyle(
                                    color: introductionColor,
                                    fontSize: introductionSize),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blue, width: 4)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black54, width: 4))),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 10, 20),
                          child: TextField(
                            enabled: false,
                            controller: _positionEtController,
                            focusNode: focusPositionNode,
                            style:
                            TextStyle(fontSize: 20.0, color: Colors.black),
                            decoration: InputDecoration(
                                labelText: "位置",
                                labelStyle: TextStyle(
                                    color: positionColor,
                                    fontSize: positionSize),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blue, width: 4)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black54, width: 4))),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 10, 20),
                          child: TextField(
                            controller: _urlEtController,
                            focusNode: focusUrlNode,
                            style:
                            TextStyle(fontSize: 20.0, color: Colors.black),
                            decoration: InputDecoration(
                                labelText: "网站",
                                labelStyle: TextStyle(
                                    color: urlColor, fontSize: urlSize),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blue, width: 4)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black54, width: 4))),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            } else {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  final _picker = ImagePicker();

  _takePhoto(String flag) async {
    var pickedFile = await _picker.getImage(source: ImageSource.camera);
    if(pickedFile == null) return;
    var image = File(pickedFile.path);

    if (flag == "banner") {
      banner = await UploadDao.uploadImage(UploadDao.UPDATE_BANNER, image);
    }else if(flag == "avatar"){
      avatar = await UploadDao.uploadImage(UploadDao.UPDATE_BANNER, image);
    }
    setState(() {});
  }

  _openGallery(String flag) async {
    var pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if(pickedFile == null) return;
    var image = File(pickedFile.path);
    if (flag == "banner") {
      banner = await UploadDao.uploadImage(UploadDao.UPDATE_BANNER, image);
    }else if(flag == "avatar"){
      avatar = await UploadDao.uploadImage(UploadDao.UPDATE_BANNER, image);
    }
    setState(() {});
  }
}