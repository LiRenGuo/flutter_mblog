import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  WebViewController _controller;
  String _title;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    Clipboard.setData(ClipboardData(text: widget.url));
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
        body: WebView(
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
        ),
      ),
    );
  }

  _launchURL() async {
    if (await canLaunch(widget.url)) {
      await launch(widget.url);
    } else {
      throw 'Could not launch ${widget.url}';
    }
  }
}
