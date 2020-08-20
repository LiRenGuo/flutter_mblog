import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

const Color selColor =Colors.white;
const Color otherColor = Colors.grey;

class ImageAllScreenLook extends StatefulWidget {

  List imgDataArr=[];
  int index=0;
  String heroTag;
  PageController controller;
  GestureTapCallback onLongPress;

  ImageAllScreenLook({
    Key key,
    @required this.imgDataArr,
    this.index,
    this.onLongPress,
    this.controller,
    this.heroTag
  }) : super(key: key){
    controller=PageController(initialPage: index);
  }

  @override
  _ImageAllScreenLookState createState() => _ImageAllScreenLookState();
}

class _ImageAllScreenLookState extends State<ImageAllScreenLook> {
  int currentIndex=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIndex=widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              right: 0,
              child:
              GestureDetector(
                child:
                Container(
                    color: Colors.black,
                    child: PhotoViewGallery.builder(
                      scrollPhysics: const BouncingScrollPhysics(),
                      builder: (BuildContext context, int index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider: NetworkImage(widget.imgDataArr[index]),
                          heroAttributes: widget.heroTag !=null?PhotoViewHeroAttributes(tag: widget.heroTag):null,
                        );
                      },
                      itemCount: widget.imgDataArr.length,
                      loadingChild: Container(),
                      backgroundDecoration: null,
                      pageController: widget.controller,
                      enableRotation: true,
                      onPageChanged: (index){
                        setState(() {
                          currentIndex=index;
                        });
                      },
                    )
                ),
                onTap: (){
                  Navigator.of(context).pop();
                },
                onLongPress: widget.onLongPress,

              )

          ),
          Positioned(
            top: MediaQuery.of(context).padding.top+30,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text("${currentIndex+1}/${widget.imgDataArr.length}",style: TextStyle(color: Colors.white,fontSize: 16)),
            ),
          ),
          Positioned(
            right: 10,
            top: MediaQuery.of(context).padding.top+15,
            child: IconButton(
              icon: Icon(Icons.close,size: 30,color: Colors.white,),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ),

          Align(
              alignment: Alignment.bottomCenter,
              child:
              Container(
//                color: Colors.red,
                width: widget.imgDataArr.length>=6 ? 200:widget.imgDataArr.length<3 ? 50:100,
                height: widget.imgDataArr.length==1 ? 0:50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    widget.imgDataArr.length,
                        (i) => GestureDetector(
                      child: CircleAvatar(
//                      foregroundColor: Theme.of(context).primaryColor,
                        radius: 5.0,
                        backgroundColor: currentIndex == i ? selColor : otherColor,
                      ),
                    ),
                  ).toList(),
                ),
              )
          )


        ],
      ),
    );
  }
}