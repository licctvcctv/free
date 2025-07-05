
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';

class DeleteAccountHttp{

  DeleteAccountHttp._internal();
  static final DeleteAccountHttp _instance = DeleteAccountHttp._internal();
  factory DeleteAccountHttp(){
    return _instance;
  }

  Future<bool> sendCode({Function(Response)? onSuccess, Function(Response)? onFail}) async{
    const String url = '/account/close/code';
    bool? result = await HttpTool.delete(url, {}, (response){
      return true;
    }, success: onSuccess, fail: onFail);
    return result ?? false;
  }

  Future<bool> closeAccount({required String code, Function(Response)? onSuccess, Function(Response)? onFail}) async{
    const String url = '/account/close';
    bool? result = await HttpTool.delete(url, {
      'code': code
    }, (response){
      return true;
    }, success: onSuccess, fail: onFail);
    return result ?? false;
  }

  Future<bool> closeAccountByWechat({required String code, Function(Response)? onSuccess, Function(Response)? onFail}) async{
    const String url = '/account/close/wechat';
    bool? result = await HttpTool.delete(url, {
      'code': code
    }, (response){
      return true;
    }, success: onSuccess, fail: onFail);
    return result ?? false;
  }

  Future<bool> closeAccountByAlipay({required String code, Function(Response)? onSuccess, Function(Response)? onFail}) async{
    const String url = '/account/close/alipay';
    bool? result = await HttpTool.delete(url, {
      'code': code
    }, (response){
      return true;
    }, success: onSuccess, fail: onFail);
    return result ?? false;
  }

  Future<bool> closeAccountByApple({required String code, Function(Response)? onSuccess, Function(Response)? onFail}) async{
    const String url = '/account/close/apple';
    bool? result = await HttpTool.delete(url, {
      'code': code
    }, (response){
      return true;
    }, fail: onFail, success: onSuccess);
    return result ?? false;
  }
}
