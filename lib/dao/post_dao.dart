import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mblog/model/mypost_model.dart';
import 'package:flutter_mblog/model/post_comment_model.dart';
import 'package:flutter_mblog/model/post_like_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/util/Configs.dart';
import 'package:flutter_mblog/util/dio_error_process.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

final POST_LIST_URL = "${Auth.ipaddress}/api/post";
final POST_COMMENT_URL = "${Auth.ipaddress}/api/comment/post";
final POST_PUBLISH_URL = "${Auth.ipaddress}/api/post";
final POST_RETWEET_URL = "${Auth.ipaddress}/api/post/quote";
final MY_POST_LIST_URL = "${Auth.ipaddress}/api/post/my";
final YOUR_POST_LIST_URL = "${Auth.ipaddress}/api/post/user/";
final LIKE_URL = '${Auth.ipaddress}/api/post/like';
final SEND_COMMENT = "${Auth.ipaddress}/api/post/";
final LIKE_POST_URI = "${Auth.ipaddress}/api/post/like/list/";
final POST_RANDOM_LIST = "${Auth.ipaddress}/api/post/list";
final FIND_KEYWORD_BY_POST = "${Auth.ipaddress}/api/post/search";

///
/// 帖子接口
class PostDao {

  /// TODO
  /// 获取首页随机帖子数，后期可能会修改
  static Future<PostModel> getRandomList(BuildContext context) async {
    print("获取首页推特数据");
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {"Authorization": "Bearer $token"});
      dio.options.connectTimeout = 5000;
      dio.options.receiveTimeout = 10000;
      final response = await dio.get(POST_RANDOM_LIST, options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        print("responseData >> ${responseData}");
        return PostModel.fromJson(responseData);
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  static Future<PostModel> findByKeyword(String keyword,BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {"Authorization": "Bearer $token"});
      dio.options.connectTimeout = 5000;
      dio.options.receiveTimeout = 10000;
      final response = await dio.get("$FIND_KEYWORD_BY_POST?keyword=$keyword", options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        print("responseData >> ${responseData}");
        return PostModel.fromJson(responseData);
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 获取评论列表
  static Future<PostCommentModel> getCommentList(
      BuildContext context, String postId) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response =
          await dio.get(POST_COMMENT_URL + "/$postId", options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        return PostCommentModel.fromJson(responseData);
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 发送评论
  static Future<PostCommentItem> sendComment(BuildContext context,
      String postId, String content, List<Asset> fileList) async {
    try {
      var formData = FormData();
      if (fileList.isNotEmpty) {
        int i = 0;
        for (Asset image in fileList) {
          ByteData byteData = await image.getByteData();
          List<int> imageData = byteData.buffer.asUint8List();
          String name = "$i.jpg";
          i++;
          MultipartFile multipartFile = MultipartFile.fromBytes(
            imageData,
            filename: name,
          );
          MapEntry<String, MultipartFile> file =
              MapEntry("files", multipartFile);
          formData.files.add(file);
          if (formData.files.length == fileList.length) {
            formData.fields.add(MapEntry("content", content));
            String token = await Shared_pre.Shared_getToken();
            Options options =
                Options(headers: {"Authorization": "Bearer $token"});
            final response = await dio.post(SEND_COMMENT + "$postId/comment",
                data: formData, options: options);
            if (response.statusCode == 200 || response.statusCode == 201) {
              final responseData = response.data;
              Navigator.pop(context);
              return PostCommentItem.fromJson(responseData);
            }
          }
        }
      } else {
        formData.fields.add(MapEntry("content", content));
        String token = await Shared_pre.Shared_getToken();
        Options options = Options(headers: {"Authorization": "Bearer $token"});
        final response = await dio.post(SEND_COMMENT + "$postId/comment",
            data: formData, options: options);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = response.data;
          Navigator.pop(context);
          return PostCommentItem.fromJson(responseData);
        }
      }
    } on DioError catch (e) {
      Navigator.pop(context);
      MyToast.show("评论失败");
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 获取我发布的帖子列表
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
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 获取别人发布的帖子列表
  static Future<MyPostModel> getYourPostList(
      BuildContext context, String userid, int page) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.get(YOUR_POST_LIST_URL + "$userid",
          options: options, queryParameters: {"page": page});
      if (response.statusCode == 200) {
        final responseData = response.data;
        return MyPostModel.fromJson(responseData);
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 发布帖子
  static Future publish(BuildContext context, FormData formData) async {
    try {
      final response = Shared_pre.Shared_getToken().then((token) async {
        Options options = Options(headers: {'Authorization': 'Bearer $token'});
        final response =
            await dio.post(POST_PUBLISH_URL, data: formData, options: options);
        return response.data;
      });
      return response;
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 转推其他帖子
  static Future retweetPublish(BuildContext context, FormData formData) async {
    try {
      final response = Shared_pre.Shared_getToken().then((token) async {
        Options options = Options(headers: {'Authorization': 'Bearer $token'});
        print("请求推文发布");
        final response =
            await dio.post(POST_RETWEET_URL, data: formData, options: options);
        return response.data;
      });
      return response;
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 喜欢这个帖子
  static Future like(String id) {
    return NetUtils.get('$LIKE_URL/$id');
  }

  ///
  /// 不喜欢这个帖子
  static Future dislike(String id) {
    return NetUtils.delete('$LIKE_URL/$id');
  }

  ///
  /// 删除帖子
  static Future<String> deletePost(String postId, BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response =
          await dio.delete(POST_LIST_URL + "/$postId", options: options);
      if (response.statusCode == 200) {
        return "success";
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 获取我点过赞的帖子列表
  static Future<PostLikeModel> getMyLikePost(
      String userId, int page, BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.get(LIKE_POST_URI + "$userId",
          options: options, queryParameters: {"page": page});
      if (response.statusCode == 200) {
        final responseData = response.data;
        return PostLikeModel.fromJson(responseData);
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  ///
  /// 根据ID获取帖子
  static Future<PostItem> getPostById(
      String postId, BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response =
          await dio.get(POST_LIST_URL + "/$postId", options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        return PostItem.fromJson(responseData);
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }
}
