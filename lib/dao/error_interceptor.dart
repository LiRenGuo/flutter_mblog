import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/main.dart';
import 'package:flutter_mblog/util/dio_error_process.dart';

class ErrorInterceptor extends Interceptor {
  @override
  Future onError(DioError err) {
    // TODO: implement onError
    LogUtil.v('DioError===: ${err.toString()}');
    BuildContext context = navigatorKey.currentState.overlay.context;
    DioErrorProcess.dioError(context, err);
    return super.onError(err);
  }
}