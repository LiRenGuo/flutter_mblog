import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Container(
          padding: EdgeInsets.all(5),
          child: CircleAvatar(
            radius: 36,
            backgroundImage: NetworkImage('http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTLYicLia9bCyRQhpCG3ofQ4dQhouIRlvnTv3DCox8v0sj9Tk01TmD3xPZTjFLxmARgEKy27T0RSC6UA/132'),
          ),
        ),
        title: Text(
          '主页',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Container(
        child: ListView.builder(
          itemBuilder: (context, index) => _item(),
        ),
      ),
    );
  }

  _item() {}
}
