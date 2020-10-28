import 'package:dio/dio.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

import 'dart:async';

var dio = new Dio();
class NetUtils {
  static Future get(String url, {Map<String, dynamic> params}) async {
    Shared_pre.Shared_getToken().then((token) async {
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      var result = await dio.get(url, options: options);
      return result.data;
    });
  }

  static Future delete(String url) async {
    var response;
    response = await Shared_pre.Shared_getToken().then((token) async {
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      try {
        var result = await dio.delete(url, options: options);
        return result.data;
      } on DioError catch (a) {
        return a.response.statusCode;
      }
    });

    return response;
  }

  static Future postcode(String url, {Map<String, dynamic> params, options}) async {
    var responseaa;
    responseaa = await Shared_pre.Shared_getToken().then((aa) async {
      Options options = Options(headers: {'Authorization': 'Bearer $aa'});
      try {
        var respose = await dio.post(url, data: params, options: options);
        if (respose.statusCode == 200) {
          return 200;
        }else{
          return 500;
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
      var respose = await dio.post(url, queryParameters: params, options: options);
      return respose.data;
    } on DioError catch (a) {
      print(a);
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
