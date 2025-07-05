
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

class UserRewardHttp{

  UserRewardHttp._internal();
  static final UserRewardHttp _instance = UserRewardHttp._internal();
  factory UserRewardHttp(){
    return _instance;
  }

  Future<String?> postReward({required int productId, required ProductType type, required int amount, Function(Response)? fail, Function(Response)? success}) async{
    const url = '/user_reward';
    String? result = await HttpTool.post(url, {
      'productId': productId,
      'productType': type.getNum(),
      'amount': amount
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return result;
  }

  Future<String?> payByAlipay({required String serial, Function(Response)? fail, Function(Response)? success}) async{
    const url = '/user_reward/pay/alipay';
    String? result = await HttpTool.get(url, {
      'serial': serial
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return result;
  }

  Future<String?> payByWechat({required String serial, Function(Response)? fail, Function(Response)? success}) async{
    const url = '/user_reward/pay/wechat';
    String? result = await HttpTool.get(url, {
      'serial': serial
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return result;
  }
}
