import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageProcessTools {

  static Widget AssetProcessImage(String url,{int cacheHeight = 250,int cacheWidth = 400}) {
    return Image.asset(url,cacheHeight: cacheHeight,cacheWidth: cacheWidth);
  }

  static Widget CachedNetworkProcessImage(String img,
      {BoxFit fit = BoxFit.cover,double height = 40 , int memCacheWidth,int memCacheHeight}) {
    print("重新加载图片");
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
      errorWidget: (context, url, error) => Image.asset("images/image_loading_error.png")/*Icon(Icons.error,color: Colors.red,)*/,
      /*errorWidget: (context, url, error) => Icon(Icons.error,color: Colors.red,),*/
    );
  }
}