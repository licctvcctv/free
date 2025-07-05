
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';

class OrderPayApi{

  OrderPayApi._internal();
  static final OrderPayApi _instance = OrderPayApi._internal();
  factory OrderPayApi(){
    return _instance;
  }

  Future<String?> payByAlipay({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/order_pay/alipay';
    String? result = await HttpTool.get(url, {
      'serial': orderSerial
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return result;
  }
  
  Future<String?> payByWechat({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/order_pay/wechat';
    String? result = await HttpTool.get(url, {
      'serial': orderSerial
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return result;
  }
}
