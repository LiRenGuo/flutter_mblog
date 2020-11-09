import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mblog/util/Configs.dart';
import 'package:flutter_mblog/util/dio_error_process.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

///
/// 上传头像和banner图接口
class UploadDao{
  static final String UPDATE_BANNER = "${Auth.ipaddress}/api/profile/update/banner";//更换背景地址
  static final String UPDATE_AVATAR = "${Auth.ipaddress}/api/profile/update/avatar";//更换头像地址

  static Future<String> uploadImage(String url,File file,BuildContext context)async{
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      Uint8List uint8list =  await file.readAsBytes();
      List<int> uint8 =  uint8list.toList();
      var formData = FormData();
      formData.files.add(MapEntry("bannerFile",MultipartFile.fromBytes(uint8,filename: "banner.jpg")));
      var respose =  await dio.post(url,data: formData,options: options);
      if (respose.statusCode == 200) {
        Navigator.pop(context);
        return respose.data;
      }
    }on DioError catch(e) {
      Navigator.pop(context);
      MyToast.show("上传失败");
      DioErrorProcess.dioError(context, e);
    }
  }
}