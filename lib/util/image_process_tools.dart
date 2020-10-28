import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// 图片处理工具
class ImageProcessTools {

  ///
  /// 本地图片处理
  static Widget AssetProcessImage(String url,{int cacheHeight = 250,int cacheWidth = 400}) {
    return Image.asset(url,cacheHeight: cacheHeight,cacheWidth: cacheWidth);
  }

  ///
  /// 网络缓存图片处理
  static Widget CachedNetworkProcessImage(String img,
      {BoxFit fit = BoxFit.cover,double height = 40 , int memCacheWidth,int memCacheHeight}) {
    return CachedNetworkImage(
      imageUrl: img,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: (context, url) {
        return Container(
          height: height,
          child: Center(
              child: Center(
                child: CircularProgressIndicator(),
              )),
        );
      },
      errorWidget: (context, url, error) => Image.asset("images/image_loading_error.png"),
    );
  }
}