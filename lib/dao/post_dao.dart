import 'package:common_utils/common_utils.dart';
import 'package:flutter_mblog/model/mypost_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/util/net_utils.dart';

const POST_LIST_URL = "http://mblog.yunep.com/api/post";
const MY_POST_LIST_URL = "http://mblog.yunep.com/api/post/my";

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

  static Future<MyPostModel> getMyPostList(int page) async{
    try{
      final response = await dio.get(MY_POST_LIST_URL, queryParameters: {"page":page});
      if (response.statusCode == 200) {
        final responseData = response.data;
        LogUtil.e("response MyPostModel = ${responseData["content"]}");
        return MyPostModel.fromJson(responseData);
      }else{
        throw Exception("loading data error.....");
      }
    }catch(e){
      print(e.toString());
    }
  }
}