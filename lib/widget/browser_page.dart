import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/util/shared_pre.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({Key key, this.url, this.title}) : super(key: key);

  final String url;
  final String title;

  @override
  _BrowserPageState createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  UserModel userModel;
  WebViewController _controller;
  String _title;
  bool isOk = false;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    getUserModel();
  }

  getUserModel()async{
    userModel = await Shared_pre.Shared_getUser();
    setState(() {
      isOk = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.blue),
            backgroundColor: Colors.white,
            title: Text(
              _title,
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              PopupMenuButton(
                  onSelected: (String value) {
                    if (value == "0") {
                      String url = widget.url.replaceFirst("app", "web");
                      Clipboard.setData(ClipboardData(text: url));
                    } else if (value == "1") {
                      _launchURL();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                        new PopupMenuItem(value: "0", child: new Text("复制连接")),
                        new PopupMenuItem(value: "1", child: new Text("在浏览器打开"))
                      ])
            ],
          ),
          body: isOk ? WebView(
            initialUrl: widget.url,
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onPageFinished: (url) {
              _controller.evaluateJavascript("document.title").then((result) {
                setState(() {
                  _title = result;
                });
              });
              _controller?.evaluateJavascript('sendUserIdFormJs("${userModel.id}")').then((value){
                print("成功调用了 >> $value");
              });
            },
            navigationDelegate: (NavigationRequest request) {
              print("request.url >> ${request.url}");
              if (request.url.startsWith("http") ||
                  request.url.startsWith("https")) {
                print("允许请求");
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },

            javascriptMode: JavascriptMode.unrestricted,
          ) : Container(),
        ),
        onWillPop: (){
          Future<bool> canGoBack = _controller.canGoBack();
          canGoBack.then((str) {
            if(str){
              _controller.goBack();
            }else{
              Navigator.of(context).pop();
            }
          });
        },
      ),
    );
  }

  _launchURL() async {
    String url = widget.url.replaceFirst("app", "web");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch ${url}';
    }
  }
}
