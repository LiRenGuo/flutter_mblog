
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mblog/util/net_utils.dart';

class UploadDao{
  static final String UPDATE_BANNER = "http://mblog.yunep.com/api/profile/update/banner";//更换背景地址
  static final String UPDATE_AVATAR = "http://mblog.yunep.com/api/profile/update/avatar";//更换头像地址


  static Future<String> uploadImage(String url,File file)async{
    Uint8List uint8list =  await file.readAsBytes();
    List<int> uint8 =  uint8list.toList();
    var formData = FormData();
    formData.files.add(MapEntry("bannerFile",MultipartFile.fromBytes(uint8,filename: "banner.jpg")));
    var respose =  await dio.post(url,data: formData);
    if (respose.statusCode == 200) {
      return respose.data;
    }else{
      throw Exception("image_upload_error ...");
    }
  }

}