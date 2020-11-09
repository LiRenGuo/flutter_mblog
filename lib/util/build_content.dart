import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/main.dart';
import 'package:flutter_mblog/pages/mine_page.dart';
import 'package:flutter_mblog/widget/browser_page.dart';
import 'package:url_launcher/url_launcher.dart';

///
/// 构建Content内容，构建信息，content中可能包含@号和链接
/// 需要区分开来
///
const String urlPattern = r'https?:/\/\\S+';
const String emailPattern = r'\S+@\S+';
const String phonePattern = r'[\d-]{9,}';
final RegExp linkRegExp = RegExp('($urlPattern)|($emailPattern)|($phonePattern)', caseSensitive: false);
class BuildContent {
  static Widget buildContent(String text, BuildContext context,
      {TextStyle style,
      int maxLines,
      bool softWrap = false,
      Function atOnTap}) {
    int flag = text.indexOf("@");
    if (flag == -1) {
      return maxLines == null
          ? Linkify(
              onOpen: _onOpen,
              text: text,
              style: style ?? TextStyle(color: Colors.black, fontSize: 15),
            )
          : Linkify(
              onOpen: _onOpen,
              text: text,
              style: style ?? TextStyle(color: Colors.black, fontSize: 15),
              maxLines: maxLines,
              softWrap: softWrap);
    } else {
      List<String> list = buildContentAt(text);
      return RichText(
        text: TextSpan(
            children: list.map((result) {
              if (result.startsWith("@")) {
                return TextSpan(
                  text: result + " ",
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      print('点击了隐私政策');
                      if (atOnTap != null) atOnTap(result.substring(1));
                    },
                );
              } else {
                return TextSpan(
                  text: result,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                );
              }
            }).toList()),
      );
    }
  }

  ///
  /// 正则表达式切割字符串
  static List<String> buildContentAt(String text) {
    List<String> matchList = [];
    RegExp regExp = new RegExp(r"@.*?\s");
    text.splitMapJoin(regExp, onMatch: (match) {
      matchList.add(match.group(0));
    }, onNonMatch: (nonMatch) {
      matchList.add(nonMatch.trim());
    });
    return matchList;
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

  static bool checkName(String name, BuildContext context) {
    try {
      UserDao.getIdByName(name, context);
      return true;
    } catch (e) {
      return false;
    }
  }
}
