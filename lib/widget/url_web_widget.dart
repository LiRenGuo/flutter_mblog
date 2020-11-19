import 'package:flutter/material.dart';
import 'package:flutter_mblog/model/user_model.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'browser_page.dart';

// ignore: must_be_immutable
class UrlWebWidget extends StatefulWidget {
  String urlWeb;
  /// 谁点开了这个网页
  String userId;

  UrlWebWidget(this.urlWeb,this.userId);

  @override
  _UrlWebWidgetState createState() => _UrlWebWidgetState();
}

class _UrlWebWidgetState extends State<UrlWebWidget> {
  WebViewController _webViewController;
  String _title = "";

  @override
  Widget build(BuildContext context) {
    print(widget.userId);
    return Padding(
      child: Container(
        child: Column(
          children: [
            Container(
              height: AdaptiveTools.setRpx(400),
              child: Stack(
                children: [
                  Container(
                    child: WebView(
                      initialUrl: "${widget.urlWeb}?userId=${widget.userId}",
                      onWebViewCreated: (controller) {
                        _webViewController = controller;
                      },
                      onPageFinished: (url) {
                        _webViewController
                            .evaluateJavascript("document.title")
                            .then((result) {
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
                    height: AdaptiveTools.setRpx(300),
                  ),
                  InkWell(
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title.replaceAll('"', ""),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: AdaptiveTools.setRpx(10),
                          ),
                          Text(
                            "${widget.urlWeb}?userId=${widget.userId}",
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                      padding: EdgeInsets.only(
                          top: AdaptiveTools.setRpx(310),
                          left: AdaptiveTools.setRpx(20)),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BrowserPage(
                                url: widget.urlWeb + "?userId=${widget.userId}",
                                title: _title,
                              )));
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
    );
  }
}
