import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_mblog/main.dart';
import 'package:flutter_mblog/widget/browser_page.dart';
import 'package:url_launcher/url_launcher.dart';

///
/// 构建Content内容，构建信息，content中可能包含@号和链接
/// 需要区分开来
class BuildContent {
  static Widget buildContent(String text, BuildContext context,
      {TextStyle style,
      int maxLines,
      bool softWrap = false,
      Function atOnTap}) {
    List<String> list = buildContentAt(text, []);
    if (list.isEmpty) {
      return maxLines == null
          ? Linkify(
              onOpen: _onOpen,
              text: text,
              style: style ?? TextStyle(color: Colors.black, fontSize: 14),
            )
          : Linkify(
              onOpen: _onOpen,
              text: text,
              style: style ?? TextStyle(color: Colors.black, fontSize: 14),
              maxLines: maxLines,
              softWrap: softWrap);
    } else {
      return RichText(
        text: TextSpan(
            children: list.map((result) {
          if (result.startsWith("@")) {
            return TextSpan(
              text: result + " ",
              style: TextStyle(fontSize: 12, color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print('点击了隐私政策');
                  if (atOnTap != null) atOnTap(result.substring(1));
                },
            );
          } else {
            return TextSpan(
              text: result,
              style: TextStyle(fontSize: 12, color: Colors.black),
            );
          }
        }).toList()),
      );
    }
  }

  ///
  /// 可能需要修改，想到好的可以修改，该方法中使用了递归，可能会比较耗性能
  static List<String> buildContentAt(String text, List<String> textList) {
    for (int i = text.length - 1; i >= 0; i--) {
      String flag = text[i];
      if (flag == " ") {
        int lastAt = text.lastIndexOf("@");
        if (lastAt == -1) {
          return [];
        }
        String at = text.substring(lastAt, i);
        text = text.substring(0, lastAt);
        if (textList.isNotEmpty) {
          textList.removeAt(0);
        }
        textList.insert(0, at);
        if (text.isNotEmpty) {
          textList.insert(0, text);
          /// 递归处
          return buildContentAt(text, textList);
        } else {
          return textList;
        }
      }
      return textList;
    }
  }

  ///
  /// 如果Content中有链接，则使用这个打开链接
  static Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      Navigator.of(navigatorKey.currentState.overlay.context)
          .push(MaterialPageRoute(builder: (_) {
        return new BrowserPage(
          url: link.url,
          title: link.text,
        );
      }));
    } else {
      throw 'Could not launch $link';
    }
  }
}
