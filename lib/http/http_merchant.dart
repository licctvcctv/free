
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_util.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/toast_util.dart';

class HttpMerchant{

  static Future<HttpResultObject<UserModel>> bindWechat(String code, {String? mode, Function(Response)? fail, Function(Response)? success}) async{
    String url = '/merchant/bind/wechat';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.put(url, data: {
      'code': code,
      'mode': mode
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('绑定微信失败');
      }
      else{
        fail(response);
      }
      int code = response.data != null ? response.data['code'] : ResultCode.RES_NOT_FOUND;
      return HttpResultObject(code, null);
    }
    if(success != null){
      success(response);
    }
    UserModel? user = UserModel.fromJson(response.data['data']);
    return HttpResultObject(ResultCode.RES_OK, user);
  }

  static Future<String?> aliGetAuth({Function(Response)? fail, Function(Response)? success}) async{
    String url = '/account/alipay/auth';
    Response response = await httpUtil.get(url);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取凭证失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    return response.data['data'];
  }

  static Future<UserModel?> aliRegiste(String code, {String? mode, Function(Response)? fail, Function(Response)? success}) async{
    String url = '/account/alipay/registe';
    Response response = await httpUtil.get(url, data: {
      'code': code,
      'mode': mode
    });
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('支付宝登录失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    UserModel? user = UserModel.fromJson(response.data['data']);
    return user;
  }

  static Future<HttpResultObject<UserModel>> aliBind(String code, {String? mode, Function(Response)? fail, Function(Response)? success}) async{
    String url = '/merchant/bind/alipay';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.put(url, data: {
      'code': code,
      'mode': mode
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('绑定支付宝失败');
      }
      else{
        fail(response);
      }
      int code = response.data != null ? response.data['code'] : ResultCode.RES_NOT_FOUND;
      return HttpResultObject(code, null);
    }
    if(success != null){
      success(response);
    }
    UserModel? user = UserModel.fromJson(response.data['data']);
    return HttpResultObject(ResultCode.RES_OK, user);
  }
}
