import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mblog/dao/user_dao.dart';
import 'package:flutter_mblog/util/AdaptiveTools.dart';
import 'package:flutter_mblog/util/common_util.dart';
import 'package:flutter_mblog/util/my_toast.dart';
import 'package:flutter_mblog/util/shared_pre.dart';

// ignore: must_be_immutable
class SettingsEditUserNamePage extends StatefulWidget {
  String username;
  SettingsEditUserNamePage(this.username);
  @override
  _SettingsEditUserNamePageState createState() => _SettingsEditUserNamePageState();
}

class _SettingsEditUserNamePageState extends State<SettingsEditUserNamePage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _oldUserNameController = new TextEditingController();
  TextEditingController _newUserNameController = new TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    _oldUserNameController.dispose();
    _newUserNameController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _oldUserNameController.text = "@"+widget.username;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('更改用户名', style: TextStyle(color: Colors.black)),
          iconTheme: IconThemeData(color: Colors.blue),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text("当前"),
                  ),
                  Container(
                    child: TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                      ),
                      controller: _oldUserNameController,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    margin: EdgeInsets.only(bottom: 10),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Text("新"),
                  ),
                  Container(
                    child: TextFormField(
                      validator: (value){
                        return value.isNotEmpty && value != null && value != "" ?null:"用户名不能为空";
                      },
                      maxLength: 15,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z]|[0-9]")),
                      ],
                      decoration: InputDecoration(
                        prefixText: "@"
                      ),
                      controller: _newUserNameController,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    margin: EdgeInsets.only(bottom: 10),
                  )
                ],
              ),
              Spacer(),
              Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 1,
                      color: Colors.black38,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: AdaptiveTools.setPx(280)),
                      margin: EdgeInsets.only(right: 10),
                      alignment: Alignment.bottomRight,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20))),
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            "完成",
                            style: TextStyle(
                                fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _editUserName();
                          }
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  _editUserName(){
    FormData formData = FormData.fromMap({"username":_newUserNameController.text});
    CommonUtil.showLoadingDialog(context);
    UserDao.editUserName(context,formData).then((value){
      if (value == "success") {
        Navigator.pop(context);
        Navigator.pop(context);
        Shared_pre.Shared_deleteUserName();
        Shared_pre.Shared_setUserName(_newUserNameController.text);
      }else{
        Navigator.pop(context);
        MyToast.show("修改用户名失败");
      }
    });
  }

}

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final regEx = RegExp(r"^\d*\.?\d*");
    String newString = regEx.stringMatch(newValue.text) ?? "";
    return newString == newValue.text ? newValue : oldValue;
  }
}
