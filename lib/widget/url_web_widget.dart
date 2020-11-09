import 'package:flutter/material.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'browser_page.dart';

// ignore: must_be_immutable
class UrlWebWidget extends StatefulWidget {
  String urlWeb;

  UrlWebWidget(this.urlWeb);

  @override
  _UrlWebWidgetState createState() => _UrlWebWidgetState();
}

class _UrlWebWidgetState extends State<UrlWebWidget> {
  WebViewController _webViewController;
  String _title = "";

  @override
  Widget build(BuildContext context) {
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
                      initialUrl: widget.urlWeb,
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
                            _title,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: AdaptiveTools.setRpx(10),
                          ),
                          Text(
                            "${widget.urlWeb}",
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
                                url: widget.urlWeb,
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
