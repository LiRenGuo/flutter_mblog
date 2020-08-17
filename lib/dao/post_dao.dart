import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/util/net_utils.dart';

const POST_LIST_URL = "http://mblog.yunep.com/api/post";

class PostDao {

  static Future<PostModel> getList(int page) async {
    final response = await dio.get(POST_LIST_URL, queryParameters: { "page": page });
    if(response.statusCode == 200) {
      final responseData = response.data;
      print("response = ${responseData['content']}");
      return PostModel.fromJson(responseData);
    } else {
      throw Exception('loading data error.....');
    }
  }
}