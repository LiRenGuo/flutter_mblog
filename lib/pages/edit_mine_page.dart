import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/dao/upload_dao.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
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

  bool onUpdate = false;
  bool isFanqi = false;

  bool onInitBody = true;

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
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
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
                  FormData formDate = FormData.fromMap({
                    "id": _userModel.id,
                    "name": _nameEtController.text,
                    "banner": banner,
                    "avatar": avatar,
                    "intro": _introductionEtController.text,
                    "homepage": _urlEtController.text,
                  });
                  Shared_pre.Shared_deleteUser();
                  UserModel editUserModel = new UserModel(email: _userModel.email,mobile: _userModel.mobile,name: _nameEtController.text,username: _userModel.username,avatar: avatar,id: _userModel.id);
                  Shared_pre.Shared_setUser(editUserModel);
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
              if (onInitBody) {
                if (_nameEtController.text.isEmpty) {
                  _nameEtController.text = _userModel.name;
                }
                if (_introductionEtController.text.isEmpty) {
                  _introductionEtController.text = _userModel.intro;
                }
                if (_urlEtController.text.isEmpty) {
                  _urlEtController.text = _userModel.homepage;
                }
                if (_positionEtController.text.isEmpty) {
                  _positionEtController.text = _userModel.address;
                }
                onInitBody = false;
              }
              return Container(
                child: ListView(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              height: AdaptiveTools.setPx(140),
                              width: MediaQuery.of(context).size.width,
                              child: banner != null
                                  ? Image.network(
                                      banner,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      _userModel.banner,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            InkWell(
                                child: Container(
                                  height: AdaptiveTools.setPx(140),
                                  padding: EdgeInsets.only(
                                      top: AdaptiveTools.setPx(60)),
                                  alignment: Alignment.topCenter,
                                  color: Colors.black38,
                                  child: Container(
                                    height: AdaptiveTools.setPx(25),
                                    child: Image.asset(
                                      "images/ic_vector_camera_stroke.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    onUpdate = true;
                                  });
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Stack(
                                          children: <Widget>[
                                            Container(
                                              height: 25,
                                              width: double.infinity,
                                              color: Colors.black54,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                ),
                                              ),
                                              height: AdaptiveTools.setPx(140),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  InkWell(
                                                    child: Container(
                                                      child: Text(
                                                        "拍照",
                                                        style: TextStyle(
                                                            fontSize:
                                                            AdaptiveTools.setPx(
                                                                17)),
                                                      ),
                                                      margin: EdgeInsets.all(10),
                                                      width: double.infinity,
                                                      alignment: Alignment.center,
                                                    ),
                                                    onTap: () {
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
                                                              fontSize:
                                                              AdaptiveTools
                                                                  .setPx(17))),
                                                      width: double.infinity,
                                                      alignment: Alignment.center,
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
                                                              fontSize:
                                                              AdaptiveTools
                                                                  .setPx(17))),
                                                      width: double.infinity,
                                                      alignment: Alignment.center,
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        );
                                      });
                                })
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
                                      backgroundImage: avatar != null
                                          ? NetworkImage(avatar)
                                          : NetworkImage(_userModel.avatar)),
                                  margin: EdgeInsets.only(
                                      left: AdaptiveTools.setPx(18),
                                      bottom: AdaptiveTools.setPx(10)),
                                )),
                            InkWell(
                              child: Container(
                                height: AdaptiveTools.setPx(80),
                                padding: EdgeInsets.all(AdaptiveTools.setPx(30)),
                                decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(40))),
                                margin: EdgeInsets.only(
                                    top: AdaptiveTools.setPx(110),
                                    left: AdaptiveTools.setPx(18)),
                                child: Container(
                                  height: AdaptiveTools.setPx(25),
                                  child: Image.asset(
                                    "images/ic_vector_camera_stroke.png",
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onTap: () {
                                print("修改头像");
                                setState(() {
                                  onUpdate = true;
                                });
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Stack(
                                        children: <Widget>[
                                          Container(
                                            height: 25,
                                            width: double.infinity,
                                            color: Colors.black54,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                            height: AdaptiveTools.setPx(140),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: <Widget>[
                                                InkWell(
                                                  child: Container(
                                                    child: Text(
                                                      "拍照",
                                                      style: TextStyle(
                                                          fontSize:
                                                          AdaptiveTools.setPx(
                                                              17)),
                                                    ),
                                                    margin: EdgeInsets.all(10),
                                                  ),
                                                  onTap: () {
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
                                                            fontSize:
                                                            AdaptiveTools
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
                                                            fontSize:
                                                            AdaptiveTools
                                                                .setPx(17))),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      );
                                    });
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(9, 5, 10, 0),
                              child: Text(
                                "用户名",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w100,
                                    color: Colors.black87),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                              child: TextField(
                                controller: _nameEtController,
                                focusNode: focusNameNode,
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                                onChanged: (value) {
                                  setState(() {
                                    onUpdate = true;
                                  });
                                },
                                decoration: InputDecoration(
                                    hintText: "请输入用户名",
                                    hintStyle: TextStyle(fontSize: 16),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.blue)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black26))),
                              ),
                            )
                          ],
                        ),
                        Stack(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(9, 5, 10, 0),
                              child: Text(
                                "简介",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w100,
                                    color: Colors.black87),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                              child: TextField(
                                maxLines: 3,
                                controller: _introductionEtController,
                                focusNode: focusIntroductionNode,
                                onChanged: (value) {
                                  setState(() {
                                    onUpdate = true;
                                  });
                                },
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                                decoration: InputDecoration(
                                    hintText: "请输入简介",
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.blue)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black26))),
                              ),
                            )
                          ],
                        ),
                        Stack(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(9, 5, 10, 0),
                              child: Text(
                                "位置",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w100,
                                    color: Colors.black87),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                              child: TextField(
                                  controller: _positionEtController,
                                  focusNode: focusPositionNode,
                                  onChanged: (value) {
                                    setState(() {
                                      onUpdate = true;
                                    });
                                  },
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.black),
                                  decoration: InputDecoration(
                                      hintText: "请输入位置",
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.blue)),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black26)))),
                            )
                          ],
                        ),
                        Stack(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(9, 5, 10, 0),
                              child: Text(
                                "网址",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w100,
                                    color: Colors.black87),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                              child: TextField(
                                controller: _urlEtController,
                                focusNode: focusUrlNode,
                                onChanged: (value) {
                                  setState(() {
                                    onUpdate = true;
                                  });
                                },
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                                decoration: InputDecoration(
                                    hintText: "请输入你的网址",
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.blue)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black26))),
                              ),
                            )
                          ],
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
    if (pickedFile == null) return;
    var image = File(pickedFile.path);

    if (flag == "banner") {
      banner = await UploadDao.uploadImage(UploadDao.UPDATE_BANNER, image);
    } else if (flag == "avatar") {
      avatar = await UploadDao.uploadImage(UploadDao.UPDATE_BANNER, image);
    }
    setState(() {});
  }

  _openGallery(String flag) async {
    var pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    var image = File(pickedFile.path);
    if (flag == "banner") {
      banner = await UploadDao.uploadImage(UploadDao.UPDATE_BANNER, image);
    } else if (flag == "avatar") {
      avatar = await UploadDao.uploadImage(UploadDao.UPDATE_BANNER, image);
    }
    setState(() {});
  }
}
