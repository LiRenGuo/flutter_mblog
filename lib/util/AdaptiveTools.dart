import 'dart:ui';

import 'package:flutter/material.dart';

class AdaptiveTools {
  static MediaQueryData _mediaQueryData = MediaQueryData.fromWindow(window);
  static double screenWidth = _mediaQueryData.size.width;
  static double screenHeight = _mediaQueryData.size.height;
  static double pixelRatio = _mediaQueryData.devicePixelRatio;
  static double rpx;
  static double px;

  static void initialize({double standardWidth = 750}) {
    rpx = screenWidth / standardWidth;
    px = screenWidth / standardWidth * 2;
  }

  // 按照像素来设置
  static double setPx(double size) {
    if(rpx == null){initialize();}
    return AdaptiveTools.rpx * size * 2;
  }

  // 按照rxp来设置
  static double setRpx(double size) {
    if(rpx == null){initialize();}
    return AdaptiveTools.rpx * size;
  }

  // 获取1像素
  static double onePx(){
    if(rpx == null){initialize();}
    return 1/pixelRatio;
  }

  // 获取屏幕宽度
  static double screenW(){
    return screenWidth;
  }

  // 获取屏幕高度
  static double screenH(){
    return screenHeight;
  }
}
