import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

typedef OnCallback = void Function();

//用于错误提示
class ToastUtil {
  static int seconds = 3;
  static FToast fToast = FToast();

  static void customError(BuildContext context, String msg){
    fToast.init(context);
    fToast.showToast(
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4)
        ),
        child: Text(msg, style: const TextStyle(fontSize: 16, color: Colors.white)),
      )
    );
  }

  static void customWarn(BuildContext context, String msg){
    fToast.init(context);
    fToast.showToast(
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(4)
        ),
        child: Text(msg, style: const TextStyle(fontSize: 16, color: Colors.white)),
      )
    );
  }

  static void customHint(BuildContext context, String msg){
    fToast.init(context);
    fToast.showToast(
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(4)
        ),
        child: Text(msg, style: const TextStyle(fontSize: 16, color: Colors.white)),
      )
    );
  }

  static void warn(String msg){
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 16.0,
      webPosition: "center",
      timeInSecForIosWeb: seconds
    );
  }

  static void error(String msg) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
      webPosition: "center",
      timeInSecForIosWeb: seconds
    );
  }

  //用于提示
  static void hint(String msg) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
      webPosition: "center",
      timeInSecForIosWeb: seconds
    );
  }

  static void confirmDlg(BuildContext context, String msg, OnCallback callback) {
    showDialog(
      context: context,
      builder: (buildContext) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(msg),
          actions: [
            FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  return Colors.grey;
                }),
              ),
              onPressed: () {
                Navigator.of(buildContext).pop();
              },
              child: const Text('取消')
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(buildContext).pop();
                callback();
              },
              child: const Text('确定')
            )
          ],
        );
      }
    );
  }
}
