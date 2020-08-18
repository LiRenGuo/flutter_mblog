import 'package:dio/dio.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

var dio = new Dio();

class NetUtils {

  static Future get(String url, {Map<String, dynamic> params}) async {
    var responseToken;
    responseToken = await Shared_pre.Shared_getToken().then((aa) async {
      Options options = Options(headers: {'Authorization': 'Bearer $aa'});
      try {
        var response = await dio.get(url, options: options);
        return response.data;
      } on DioError catch (a) {
        return a.response.statusCode;
      }
    });
    return responseToken;
  }

  static Future delete(String url) async {
    var responseaa;
    responseaa = await Shared_pre.Shared_getToken().then((aa) async {
      Options options = Options(headers: {'Authorization': 'Bearer $aa'});
      try {
        var response = await dio.delete(url, options: options);
        return response.data;
      } on DioError catch (a) {
        return a.response.statusCode;
      }
    });

    return responseaa;
  }

  static Future postcode(String url, {Map<String, dynamic> params, options}) async {
    var responseaa;
    responseaa = await Shared_pre.Shared_getToken().then((aa) async {
      Options options = Options(headers: {'Authorization': 'Bearer $aa'});
      try {
        var respose = await dio.post(url, data: params, options: options);
        if (respose.statusCode == 200) {
          return 200;
        }
      } on DioError catch (a) {
        print(a.response.data);
        return a.response.statusCode;

        //  Register.fromJson(a.response);
      }
    });
  }

  static Future postdata(String url,
      {Map<String, dynamic> params, options}) async {
    try {
      var respose =
          await dio.post(url, queryParameters: params, options: options);
      print(respose.data);
      return respose.data;
    } on DioError catch (a) {
      print(a.response.statusCode);
      return a.response.statusCode;
      //  Register.fromJson(a.response);
    }
  }

  static Future upload(String url, FormData formData) async {
    var resposeaaa;
    resposeaaa = Shared_pre.Shared_getToken().then((aa) async {
      Options options = Options(headers: {'Authorization': 'Bearer $aa'});
      var respose = await dio.post(url, data: formData, options: options);
    return respose.data;
    });
    return resposeaaa;
  }

  static Future basispost(String url,FormData formData) async {
    var respose;
    respose = await dio.post(url,data: formData); 
    return respose.toString();
  }

}
