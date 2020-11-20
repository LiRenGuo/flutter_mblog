import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_mblog/model/app_info_model.dart';
import 'package:flutter_mblog/util/Configs.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

ReceivePort _port = ReceivePort();

///
/// APP更新检查
class CheckUpdateTools {
  static AppInfoModel appInfoModel;
  static String _downloadPath = '';
  static String _filename = 'app-release.apk';
  static String _taskId = '';

  check(BuildContext context,
      {bool isShowToast = true, Function showDialog}) async {
    /// 1、获取当前网络情况
    ConnectivityResult connectivityResult = await _checkConnectivity();

    /// 如果没有网络，则无法进行更新操作
    if (connectivityResult == ConnectivityResult.none) {
      print("无网络");
      MyToast.show("请检查网络情况");
      return;
    }

    /// 2、检查版本号
    bool hasNewVersion = await _checkVersion(isShowToast);
    if (!hasNewVersion) {
      return;
    }

    /// ----------- 如果是WIFI情况，开始静默下载apk -----------


    /// 3、确认下载
    bool confirm;
    if (showDialog != null) {
      confirm = await showDialog();
    } else {
      confirm = await showInstallUpdateDialog(context);
    }

    if (!confirm) {
      return;
    }

    /// 4、判断系统，ios跳转app store，安卓下载新的apk
    if (Platform.isIOS) {
      /// 4.1、如果是IOS跳转app store
    } else if (Platform.isAndroid) {
      /// 4.2、如果是安卓，直接下载
      await _prepareDownload();
      if (_downloadPath.isNotEmpty) {
        await download();
      }
    }
  }

  /// 1、检查网络情况
  Future<ConnectivityResult> _checkConnectivity() async {
    var connectivityResult = await (new Connectivity().checkConnectivity());
    return connectivityResult;
  }

  /// 2、检查版本
  Future<bool> _checkVersion(bool isShowToast) async {
    Dio dio = new Dio();
    dio.options.connectTimeout = 3000;
    dio.options.receiveTimeout = 10000;
    var res = await dio
        .get("${Auth.ipaddress}/api/app/latest/version")
        .catchError((e) {
      print('获取版本号失败---------- ${e}');
      MyToast.show("获取版本号失败");
      return;
    });
    if (res != null && res.statusCode == 200) {
      appInfoModel = AppInfoModel.fromJson(res.data);

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (packageInfo.version != appInfoModel.version) {
        return true;
      } else {
        if (isShowToast) {
          MyToast.show("暂无最新版本");
        }
      }
    }
    return false;
  }

  /// 3、 弹窗确认是否安装更新
  Future<bool> showInstallUpdateDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("检测到新版本"),
          content: Text("确认安装新版本?"),
          actions: <Widget>[
            FlatButton(
                child: Text(
                  "取消",
                  style: TextStyle(color: Color(0xff999999)),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                } // 关闭对话框
                ),
            FlatButton(
              child: Text("确认"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  /// 4、下载
  /// 4.1、下载前的准备，获取地址
  static Future<void> _prepareDownload() async {
    _downloadPath = (await _findLocalPath()) + '/Download/';
    final savedDir = Directory(_downloadPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    print('--------------------downloadPath: $_downloadPath');
  }

  /// 4.2、下载apk
  static Future<void> download() async {
    final bool _permissionReady = await _checkPermission();
    if (_permissionReady) {
      IsolateNameServer.registerPortWithName(
          _port.sendPort, 'downloader_send_port');
      _port.listen((dynamic data) async {
        String id = data[0];
        DownloadTaskStatus status = data[1];
        int progress = data[2];
        if (status == DownloadTaskStatus.complete) {
          // 更新弹窗提示，确认后进行安装
          OpenFile.open('$_downloadPath/$_filename');
          print(
              '==============_installApkz: $_taskId  $_downloadPath /$_filename');
        }
      });
      _taskId = await FlutterDownloader.enqueue(
          url: appInfoModel.path,
          savedDir: _downloadPath,
          fileName: _filename,
          showNotification: true,
          openFileFromNotification: true);
    } else {
      print('-----------------未授权');
    }
  }

  /// 静默下载apk，如果在WIFI情况下，自动下载最新的apk放到文件夹中
  static Future<void> silentDownload() async{
    /// 1、检查权限
    final bool _permissionReady = await _checkPermission();
    if(_permissionReady){
      String silentDownloadPath =  await _prepareSilentDownload();

    }else{
      print('-----------------未授权');
    }
  }

  static Future<String> _prepareSilentDownload() async {
    String downloadPath = (await _findLocalPath()) + '/Download/';
    final savedDir = Directory(downloadPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      await savedDir.create();
    }
    print('--------------------downloadPath: $_downloadPath');
    print("--------------------downloadFile：${savedDir.listSync().map((e) {
      print(e.path);
    })}");
    return downloadPath;
  }

  /// 检查权限
  static Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      // 检查是否已有读写内存的权限
      bool status = await Permission.storage.isGranted;
      //判断如果还没拥有读写权限就申请获取权限
      if (!status) {
        return await Permission.storage.request().isGranted;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  /// 获取下载地址
  static Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }
}
