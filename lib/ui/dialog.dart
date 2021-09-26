import 'package:flutter/material.dart';

class AppDialog {
  static final AppDialog _singleton = AppDialog._internal();

  factory AppDialog() {
    return _singleton;
  }

  AppDialog._internal();

  bool _isShown = false;

  void showConfirm(BuildContext context, String title, String text, Function callback) {
    if (_isShown) {
      return;
    }

    _isShown = true;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: ThemeData.dark().backgroundColor,
          title: Text(title, style: ThemeData.dark().textTheme.bodyText1),
          content: Text(text, style: ThemeData.dark().textTheme.bodyText2),
          actions: <Widget>[
            FlatButton(
                child: Text("キャンセル", style: ThemeData.dark().textTheme.button),
                onPressed: () {
                  Navigator.pop(context);
                }),
            FlatButton(
                child: const Text("削除する",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                    )),
                onPressed: () {
                  Navigator.pop(context);
                  callback();
                }),
          ],
        );
      },
    ).then((res) {
      _isShown = false;
    });
  }
}
