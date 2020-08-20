import 'package:dio/dio.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mblog/model/mypost_model.dart';
import 'package:flutter_mblog/model/post_comment_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:flutter_mblog/util/oauth.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

const POST_LIST_URL = "http://mblog.yunep.com/api/post";
const POST_COMMENT_URL = "http://mblog.yunep.com/api/comment/post/";
const POST_PUBLISH_URL = "http://mblog.yunep.com/api/post";
const MY_POST_LIST_URL = "http://mblog.yunep.com/api/post/my";
const LIKE_URL = 'http://mblog.yunep.com/api/post/like'; //点赞接口
const SEND_COMMENT = "http://mblog.yunep.com/api/post/";

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

  static Future<PostCommentModel> getCommentList(String postId) async {
    final response = await dio.get(POST_COMMENT_URL + "/$postId");
    if (response.statusCode == 200) {
      final responseData = response.data;
      print("数据" + responseData.toString());
      return PostCommentModel.fromJson(responseData);
    } else {
      throw Exception("loading data error.....");
    }
  }

  static Future<PostCommentItem> sendComment(
      BuildContext context, String postId, String content,  List<Asset> fileList) async {
    var formData = FormData();
    if (fileList.isNotEmpty){
      int i = 0;
      for(Asset image in fileList){
        ByteData byteData =  await image.getByteData(quality: 2);
        List<int> imageData = byteData.buffer.asUint8List();
        String name = "$i.jpg";
        i++;
        MultipartFile multipartFile = MultipartFile.fromBytes(
          imageData,
          filename: name,
        );
        MapEntry<String, MultipartFile> file = MapEntry("files", multipartFile);
        formData.files.add(file);
        if (formData.files.length == fileList.length) {
          formData.fields.add(MapEntry("content", content));
          String token = await Shared_pre.Shared_getToken();
          Options options = Options(headers: {"Authorization": "Bearer $token"});
          final response = await dio.post(SEND_COMMENT + "$postId/comment",
              data: formData, options: options);
          if (response.statusCode == 200 || response.statusCode == 201) {
            final responseData = response.data;
            print("数据:${responseData}");
            return PostCommentItem.fromJson(responseData);
          } else if (response.statusCode == 401) {
            Oauth_2.ResToken(context);
          } else {
            throw Exception("send error");
          }
        }
      }
    }else{
      formData.fields.add(MapEntry("content", content));
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {"Authorization": "Bearer $token"});
      final response = await dio.post(SEND_COMMENT + "$postId/comment",
          data: formData, options: options);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        print("数据:${responseData}");
        return PostCommentItem.fromJson(responseData);
      } else if (response.statusCode == 401) {
        Oauth_2.ResToken(context);
      } else {
        throw Exception("send error");
      }
    }
  }

  static Future<MyPostModel> getMyPostList(
      BuildContext context, int page) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.get(MY_POST_LIST_URL,
          options: options, queryParameters: {"page": page});
      if (response.statusCode == 200) {
        final responseData = response.data;
        return MyPostModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        Oauth_2.ResToken(context);
      } else {
        throw Exception("loading data error.....");
      }
    } catch (e) {
      print(e.toString());
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

  static Future like(String id) {
    return NetUtils.get('$LIKE_URL/$id');
  }

  static Future dislike(String id) {
    return NetUtils.delete('$LIKE_URL/$id');
  }
}