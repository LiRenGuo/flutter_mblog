import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

ReceivePort _port = ReceivePort();

class AppInfo {
  AppInfo();

  String version;

  AppInfo.fromJson(Map<String, dynamic> json) : version = json['version'];
}

///
/// APP更新检查
class CheckUpdateTools {
  static String _downloadPath = '';
  static String _filename = 'app-release.apk';
  static String _taskId = '';

  check(BuildContext context,
      {bool isShowToast = true, Function showDialog}) async {
    bool hasNewVersion = await _checkVersion(isShowToast);
    if (!hasNewVersion) {
      return;
    }
    bool confirm;
    if (showDialog != null) {
      confirm = await showDialog();
    } else {
      confirm = await showInstallUpdateDialog(context);
    }
    if (!confirm) {
      return;
    }

    // 判断系统，ios跳转app store，安卓下载新的apk
    if (Platform.isIOS) {
      // 跳转app store
    } else if (Platform.isAndroid) {
      await _prepareDownload();
      if (_downloadPath.isNotEmpty) {
        await download();
      }
    }
  }

  // 弹窗确认是否安装更新
  Future<bool> showInstallUpdateDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("检测到新版本"),
          content: Text("已准备好更新，确认安装新版本?"),
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

  // 下载前的准备
  static Future<void> _prepareDownload() async {
    _downloadPath = (await _findLocalPath()) + '/Download';
    final savedDir = Directory(_downloadPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    print('--------------------downloadPath: $_downloadPath');
  }

  // 获取下载地址
  static Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }

  /// 检查版本
  Future<bool> _checkVersion(bool isShowToast) async {
    var res =
        await Dio().get("http://10.1.53.16:8990/demo/version").catchError((e) {
      print('获取版本号失败---------- ${e}');
    });
    if (res.statusCode == 200) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (packageInfo.version != res.data) {
        return true;
      } else {
        if (isShowToast) {
          MyToast.show("暂无最新版本");
        }
      }
    }
    return false;
  }

  // 下载apk
  static Future<void> download() async {
    final bool _permissionReady = await _checkPermission();
    if (_permissionReady) {
      // final taskId = await downloadApk();
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

      FlutterDownloader.registerCallback(downloadCallback);
      _taskId = await FlutterDownloader.enqueue(
          url:
              'http://10.1.53.16:8990/demo/download?id=02578ecd80f343799226d56c4c93a754',
          savedDir: _downloadPath,
          fileName: _filename,
          showNotification: true,
          openFileFromNotification: true);
    } else {
      print('-----------------未授权');
    }
  }

  // 下载完成之后的回调
  static downloadCallback(id, status, progress) {
    print('Download task ($id) is in status ($status) and process ($progress)');
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
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
}
