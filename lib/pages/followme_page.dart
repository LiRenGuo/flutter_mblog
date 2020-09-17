import 'package:flutter/material.dart';

class FollowMePage extends StatefulWidget {
  @override
  _FollowMePageState createState() => _FollowMePageState();
}

class _FollowMePageState extends State<FollowMePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.blue),
          backgroundColor: Colors.white,
          title: Text("关注者",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: Container(
          color: Color(0xffE7ECF0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text("你尚无任何关注者",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text("当有人关注你时，你将会在这里看到他们。",style: TextStyle(color: Colors.black87,fontSize: 12),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
