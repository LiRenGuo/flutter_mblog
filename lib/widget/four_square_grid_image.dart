import 'package:flutter/material.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/image_process_tools.dart';
import 'package:flutter_mblog/widget/fade_route.dart';
import 'package:flutter_mblog/widget/image_all_screen_look.dart';

class FourSquareGridImage{

  static _showImage(BuildContext context,List<String> photos, int index) {
    Navigator.of(context).push(FadeRoute(
        page: ImageAllScreenLook(
          imgDataArr: photos,
          index: index,
        )));
  }

  static Widget buildImage(BuildContext context,List<String> photos,{double width = double.infinity,int memCacheHeight = 250,int memCacheWidth = 400}) {
    Widget imageWidget;
    switch (photos.length) {
      case 1:
        imageWidget = GestureDetector(
          child: Container(
              height: 150,
              width: width,
              margin: EdgeInsets.only(top: 3),
              child: ClipRRect(
                child: ImageProcessTools.CachedNetworkProcessImage(photos[0],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                borderRadius: BorderRadius.circular(8),
              )),
          onTap: () => _showImage(context,photos, 0),
        );
        break;
      case 2:
        imageWidget = Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8))),
          height: 150,
          width: width,
          margin: EdgeInsets.only(top: 3),
          child: Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  child: Container(
                      height: double.infinity,
                      child: ClipRRect(
                        child: ImageProcessTools.CachedNetworkProcessImage(photos[0],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8)),
                      )),
                  onTap: () => _showImage(context,photos, 0),
                ),
              ),
              SizedBox(
                width: 3,
              ),
              Expanded(
                child: GestureDetector(
                  child: Container(
                    height: double.infinity,
                    child: ClipRRect(
                      child: ImageProcessTools.CachedNetworkProcessImage(photos[1],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8)),
                    ),
                  ),
                  onTap: () => _showImage(context,photos, 1),
                ),
              )
            ],
          ),
        );
        break;
      case 3:
        imageWidget = Container(
          height: 150,
          width: width,
          margin: EdgeInsets.only(top: 3),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          child: ClipRRect(
                            child: ImageProcessTools.CachedNetworkProcessImage(photos[0],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8)),
                          ),
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        onTap: () => _showImage(context,photos, 0),
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: ImageProcessTools.CachedNetworkProcessImage(photos[1],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context,photos, 1),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: ImageProcessTools.CachedNetworkProcessImage(photos[2],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context,photos, 2),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      case 4:
        imageWidget = Container(
          height: 150,
          width: width,
          margin: EdgeInsets.only(top: 3),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: ImageProcessTools.CachedNetworkProcessImage(photos[0],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context,photos, 0),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: ImageProcessTools.CachedNetworkProcessImage(photos[1],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context,photos, 1),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: ImageProcessTools.CachedNetworkProcessImage(photos[2],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context,photos, 2),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Expanded(
                            child: GestureDetector(
                              child: Container(
                                child: ClipRRect(
                                  child: ImageProcessTools.CachedNetworkProcessImage(photos[3],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(8)),
                                ),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              onTap: () => _showImage(context,photos, 3),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      default:
        imageWidget = Container();
        break;
    }
    return imageWidget;
  }

  static Widget buildRetweetImage(List<String> photos,{int memCacheHeight = 250,int memCacheWidth = 400}) {
    Widget widgets;
    switch (photos.length) {
      case 1:
        widgets = Container(
            height: AdaptiveTools.setRpx(180),
            margin: EdgeInsets.only(top: 5),
            width: double.infinity,
            child: ClipRRect(
              child: ImageProcessTools.CachedNetworkProcessImage(photos[0],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10)),
            ));
        break;
      case 2:
        widgets = Container(
          height: AdaptiveTools.setRpx(180),
          margin: EdgeInsets.only(top: 5),
          width: double.infinity,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: ClipRRect(
                    child: ImageProcessTools.CachedNetworkProcessImage(photos[0],
                        memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Container(
                  child: ClipRRect(
                    child: ImageProcessTools.CachedNetworkProcessImage(photos[1],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case 3:
        widgets = Container(
          height: AdaptiveTools.setRpx(280),
          margin: EdgeInsets.only(top: 5),
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: double.infinity,
                        child: ClipRRect(
                          child: ImageProcessTools.CachedNetworkProcessImage(photos[0],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: ClipRRect(
                                child: ImageProcessTools.CachedNetworkProcessImage(photos[1],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: ClipRRect(
                                child: ImageProcessTools.CachedNetworkProcessImage(photos[2],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      case 4:
        widgets = Container(
          height: AdaptiveTools.setRpx(280),
          margin: EdgeInsets.only(top: 5),
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: ClipRRect(
                          child: ImageProcessTools.CachedNetworkProcessImage(photos[0],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        child: ClipRRect(
                          child: ImageProcessTools.CachedNetworkProcessImage(photos[1],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: ClipRRect(
                          child: ImageProcessTools.CachedNetworkProcessImage(photos[2],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        child: ClipRRect(
                          child: ImageProcessTools.CachedNetworkProcessImage(photos[3],memCacheHeight: memCacheHeight,memCacheWidth: memCacheWidth),/*CacheImage.cachedImage(photos[0]),*/
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
        break;
      default:
        widgets = Container();
        break;
    }
    return widgets;
  }
}
