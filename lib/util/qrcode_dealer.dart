
import 'dart:convert';

import 'package:freego_flutter/http/http_qrcode.dart';
import 'package:freego_flutter/util/toast_util.dart';

class QRCodeDealer{

  static Future<bool> deal(String message) async{
    Map<String, Object?> map = jsonDecode(message);
    String? type = map['type'] as String?;
    if(type == null){
      return false;
    }
    switch(type){
      case 'login':
        String? code = map['content'] as String?;
        if(code == null){
          return false;
        }
        bool result = await HttpQrcode.link(code);
        if(result){
          ToastUtil.hint('处理成功');
          return true;
        }
    }
    return false;
  }
}
