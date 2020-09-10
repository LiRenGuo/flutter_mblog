import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mblog/pages/login_page.dart';

List<CameraDescription> cameras;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SafeArea(
        child: LoginPage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

