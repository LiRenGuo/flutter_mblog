/*
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/image_cache_manager.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:path_provider/path_provider.dart';

class CacheImage{
  static Future<Directory> path() async => (await getExternalCacheDirectories())[0];
  static Widget cachedImage(String img,{BoxFit fit = BoxFit.cover,double height = 40}) {
    return OptimizedCacheImage(
      imageUrl: img,
      cacheManager: ImageCacheManager.init(
          ImageCacheConfig(storagePath: path(), enableLog: !kReleaseMode)),
      fit: fit,
      placeholder: (context, url) {
        return Container(
          height: height,
          child: Center(
              child: Center(
                child: CircularProgressIndicator(),
              )),
        );
      },
    );
  }
}*/
