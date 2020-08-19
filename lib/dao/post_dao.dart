import 'package:dio/dio.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

const POST_LIST_URL = "http://mblog.yunep.com/api/post";
const POST_PUBLISH_URL = "http://mblog.yunep.com/api/post";

class PostDao {

  static Future<PostModel> getList(int page, int pageSize) async {
    final response = await dio.get(POST_LIST_URL, queryParameters: { "page": page, "size": pageSize});
    if(response.statusCode == 200) {
      final responseData = response.data;
      return PostModel.fromJson(responseData);
    } else {
      throw Exception('loading data error.....');
    }
  }

  static Future publish(FormData formData) async {
    final response = Shared_pre.Shared_getToken().then((token) async {
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      var result = await dio.post(POST_PUBLISH_URL, data: formData, options: options);
      return result.data;
    });
    return response;
  }
}