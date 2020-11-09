import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mblog/util/Configs.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/oauth.dart';

///
/// 统一Dio错误处理
class DioErrorProcess {
  DioErrorProcess.dioError(BuildContext context, DioError error) {
    print("错误报警 >>>> "+error.toString());
    print("错误请求 >>>> ${error.request.path}");
    switch (error.type) {
      case DioErrorType.CANCEL:
        MyToast.show("请求取消");
        break;
      case DioErrorType.CONNECT_TIMEOUT:
        MyToast.show("网络连接超时，请检查网络设置！");
        break;
      case DioErrorType.SEND_TIMEOUT:
        MyToast.show("请求超时，请检查网络设置！");
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        MyToast.show("服务器异常，请稍后重试！");
        break;
      case DioErrorType.RESPONSE:
        int errorCode =  error.response.statusCode;
        switch (errorCode) {
          case 401:
            print("Token过期啦");
            Oauth_2.ResToken(context);
            break;
          case 500:
            MyToast.show("服务器内部错误");
            break;
          default:
            print(error.response.statusMessage);
            MyToast.show(error.response.statusMessage);
            break;
        }
        break;
      case DioErrorType.DEFAULT:
        MyToast.show("网络异常，请稍后重试！");
        break;
    }
  }

}
