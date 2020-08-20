import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RadialExpansionDemo extends StatelessWidget {

  static const double kMinRadius = 32.0;
  static const double kMaxRadius = 128.0;

  static const opacityCurve = Interval(0.0, 0.75, curve: Curves.fastOutSlowIn);

  @override
  Widget build(BuildContext context) {
//    timeDilation = 5;
    return Scaffold(
      appBar: AppBar(
        title: Text('Radial Transition Demo'),
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        alignment: FractionalOffset.bottomLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildHero(context, 'https://zzm888.oss-cn-shenzhen.aliyuncs.com/2020/06/05/03c9ade643ef4872a760601d6f3234e5avatar.jpg', 'Chair'),
            _buildHero(context, 'https://zzm888.oss-cn-shenzhen.aliyuncs.com/default.png', 'Binoculars'),
            _buildHero(context, 'https://zzm888.oss-cn-shenzhen.aliyuncs.com/avatar.jpg', 'Beach ball'),
          ],
        ),
      ),
    );
  }

  _buildHero(BuildContext context, String imageName, String description) {
    return Container(
      width: kMinRadius * 2,
      height: kMinRadius * 2,
      child: Hero(
        tag: imageName,
        createRectTween: _createRectTween,
        child: RadialExpansion(
          maxRadius: kMaxRadius,
          child: Photo(
            photo: imageName,
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder<void>(
                 pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                   return AnimatedBuilder(
                     animation: animation,
                     builder: (BuildContext context, Widget child) {
                       return Opacity(
                         opacity: opacityCurve.transform(animation.value),
                         child: _buildPage(context, imageName, description),
                       );
                     },
                   );
                 }
                )
              );
            },
          ),
        ),
      ),
    );
  }

  Tween<Rect> _createRectTween(Rect begin, Rect end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }

  _buildPage(BuildContext context, String imageName, String description) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: Center(
        child: Card(
          elevation: 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: kMaxRadius * 2,
                height: kMaxRadius * 2,
                child: Hero(
                  tag: imageName,
                  child: RadialExpansion(
                    maxRadius: kMaxRadius,
                    child: Photo(
                      photo: imageName,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
              Text(
                description,
                style: TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 3.0,
              ),
              SizedBox(
                height: 16,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RadialExpansion extends StatelessWidget {

  final double maxRadius;
  final clipRectSize;
  final Widget child;

  const RadialExpansion({Key key, this.maxRadius, this.clipRectSize, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Center(
        child: SizedBox(
          width: clipRectSize,
          height: clipRectSize,
          child: ClipRect(
            child: child,
          ),
        ),
      ),
    );
  }
}

class Photo extends StatelessWidget {
  final String photo;
  final VoidCallback onTap;
  final double width;

  const Photo({Key key, this.photo, this.onTap, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColor.withOpacity(0.25),
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, size) {
            return Image.network(photo, fit: BoxFit.contain);
          },
        ),
      ),
    );
  }
}


