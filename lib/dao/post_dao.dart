import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mblog/model/mypost_model.dart';
import 'package:flutter_mblog/model/post_comment_model.dart';
import 'package:flutter_mblog/model/post_like_model.dart';
import 'package:flutter_mblog/model/post_model.dart';
import 'package:flutter_mblog/util/dio_error_process.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/net_utils.dart';
import 'package:flutter_mblog/util/oauth.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

const POST_LIST_URL = "http://mblog.yunep.com/api/post";
const POST_COMMENT_URL = "http://mblog.yunep.com/api/comment/post/";
const POST_PUBLISH_URL = "http://mblog.yunep.com/api/post";
const POST_RETWEET_URL = "http://mblog.yunep.com/api/post/quote";
const MY_POST_LIST_URL = "http://mblog.yunep.com/api/post/my";
const YOUR_POST_LIST_URL = "http://mblog.yunep.com/api/post/user/";
const LIKE_URL = 'http://mblog.yunep.com/api/post/like';
const SEND_COMMENT = "http://mblog.yunep.com/api/post/";
const LIKE_POST_URI = "http://mblog.yunep.com/api/post/like/list/";


const POST_RANDOM_LIST = "http://mblog.yunep.com/api/post/list";

class PostDao {

  static Future<PostModel> getRandomList(BuildContext context)async{
    print("获取首页推特数据");
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {"Authorization": "Bearer $token"});
      dio.options.connectTimeout = 5000;
      dio.options.receiveTimeout = 10000;
      final response = await dio
          .get(POST_RANDOM_LIST,options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        return PostModel.fromJson(responseData);
      } else {
        throw Exception('loading data error.....');
      }
    }on DioError catch(e) {
      DioErrorProcess.dioError(context, e);
    }
  }


  static Future<PostCommentModel> getCommentList(BuildContext context,String postId) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.get(POST_COMMENT_URL + "/$postId",options: options);
      if (response.statusCode == 200) {
        final responseData = response.data;
        print("数据" + responseData.toString());
        return PostCommentModel.fromJson(responseData);
      }
    }on DioError catch(e) {
      DioErrorProcess.dioError(context, e);
    }
  }

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
              Navigator.pop(context);
              return PostCommentItem.fromJson(responseData);
            } else if (response.statusCode == 401) {
              Oauth_2.ResToken(context);
            } else {
              throw Exception("send error");
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
        } else if (response.statusCode == 401) {
          Oauth_2.ResToken(context);
        } else {
          throw Exception("send error");
        }
      }
    } on DioError catch(e) {
      Navigator.pop(context);
      MyToast.show("评论失败");
      DioErrorProcess.dioError(context, e);
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
      } else {
        throw Exception("loading data error.....");
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

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
      } else {
        throw Exception("loading data error.....");
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
    }
  }

  static Future publish(BuildContext context, FormData formData) async {
    try {
      final response = Shared_pre.Shared_getToken().then((token) async {
        Options options = Options(headers: {'Authorization': 'Bearer $token'});
        final response = await dio.post(POST_PUBLISH_URL, data: formData, options: options);
        print("response = $response");
        if (response.statusCode == 401) {
          Oauth_2.ResToken(context);
          publish(context, formData);
        }
        return response.data;
      });
      return response;
    }on DioError catch(e) {
      /*print("e.data >> ${e.response.data["result"]}");*/
      DioErrorProcess.dioError(context, e);
    }
  }

  static Future retweetPublish(BuildContext context, FormData formData) async {
    try {
      final response = Shared_pre.Shared_getToken().then((token) async {
        Options options = Options(headers: {'Authorization': 'Bearer $token'});
        print("请求推文发布");
        final response = await dio.post(POST_RETWEET_URL, data: formData, options: options);
        print("response = $response");
        if (response.statusCode == 401) {
          Oauth_2.ResToken(context);
          publish(context, formData);
        }
        return response.data;
      });
      return response;
    }on DioError catch (e) {
/*      print("e.data >> ${e.response.data["result"]}");*/
      DioErrorProcess.dioError(context, e);
    }
  }

  static Future like(String id) {
    return NetUtils.get('$LIKE_URL/$id');
  }

  static Future dislike(String id) {
    return NetUtils.delete('$LIKE_URL/$id');
  }

  static Future<String> deletePost(String postId, BuildContext context) async {
    try {
      print("删除帖子");
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response =
          await dio.delete(POST_LIST_URL + "/$postId", options: options);
      print(response);
      if (response.statusCode == 200) {
        return "success";
      } else {
        throw Exception("loading data error.....");
      }
    } on DioError catch (e) {
      /*print(e.toString());
      if (e.response.statusCode == 401) {
        Oauth_2.ResToken(context);
      }*/
      DioErrorProcess.dioError(context, e);
    }
  }

  static Future<PostLikeModel> getMyLikePost(String userId,int page,BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.get(LIKE_POST_URI + "$userId",
          options: options, queryParameters: {"page": page});
      if (response.statusCode == 200) {
        final responseData = response.data;
        return PostLikeModel.fromJson(responseData);
      } else {
        throw Exception("loading data error.....");
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
     /* if (e.response.statusCode == 401) {
        Oauth_2.ResToken(context);
      }*/
    }
  }


  static Future<PostItem> getPostById(
      String postId, BuildContext context) async {
    try {
      String token = await Shared_pre.Shared_getToken();
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await dio.get(POST_LIST_URL + "/$postId", options: options);
      print(response);
      if (response.statusCode == 200) {
        final responseData = response.data;
        return PostItem.fromJson(responseData);
      } else {
        throw Exception("loading data error.....");
      }
    } on DioError catch (e) {
      DioErrorProcess.dioError(context, e);
      /*if (e.response.statusCode == 401) {
        Oauth_2.ResToken(context);
      }*/
    }
  }

}
