
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_util.dart';
import 'package:freego_flutter/util/storage.dart';
import 'package:freego_flutter/util/toast_util.dart';

class HttpQrcode {

  static Future<bool> link(String code, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/merchant/qrcode';
    String? token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.post(url, data: {
      'code': code
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('链接二维码失败');
      }
      else{
        fail(response);
      }
      return false;
    }
    if(success != null){
      success(response);
    }
    return true;
  }
}
