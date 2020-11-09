import 'package:flutter/material.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/check_update_tools.dart';
import 'package:package_info/package_info.dart';

class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  PackageInfo packageInfo;
  bool isok = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getVersion();
  }

  getVersion() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      isok = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: isok
            ? Column(
                children: [
                  InkWell(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(15),
                      child: Icon(Icons.chevron_left,size: 38,color: Colors.blueAccent,),
                    ),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin:
                              EdgeInsets.only(top: AdaptiveTools.setRpx(100)),
                          height: AdaptiveTools.setPx(80),
                          child: ClipRRect(
                            child: Image.asset(
                              "images/logo.png",
                              cacheHeight: 480,
                              cacheWidth: 640,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            "微博客",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                            "Version ${packageInfo.version}",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Divider(height: 5,color: Colors.black38,),
                        ListTile(
                          title: Text("检查新版本"),
                          trailing: Icon(Icons.chevron_right),
                          onTap: (){
                            CheckUpdateTools().check(context);
                          },
                        ),
                        Divider(height: 5,color: Colors.black38,),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Text("极客工作室 提供技术支持",style: TextStyle(fontSize: AdaptiveTools.setRpx(24),color: Colors.black38),)
                      ],
                    ),
                  )
                ],
              )
            : Container(),
      ),
    );
  }
}
