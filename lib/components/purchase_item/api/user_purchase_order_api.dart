
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/purchase_item/enums/pay_type.dart';
import 'package:freego_flutter/components/purchase_item/model/pre_pay_info.dart';
import 'package:freego_flutter/http/http_tool.dart';

class UserPurchaseOrderApi{

  UserPurchaseOrderApi._internal();
  static final UserPurchaseOrderApi _instance = UserPurchaseOrderApi._internal();
  factory UserPurchaseOrderApi(){
    return _instance;
  }

  Future<PrePayInfo?> orderSuit({required int suitId, bool? isGift, int? giftTo, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user_purchase_order/order/suit';
    PrePayInfo? info = await HttpTool.post(url, {
      'suitId': suitId,
      'isGift': isGift,
      'giftTo': giftTo
    }, (response){
      return PrePayInfo.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return info;
  }

  Future<String?> pay({required String serial, required PayType payType, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user_purchase_order/pay';
    String? code = await HttpTool.put(url, {
      'serial': serial,
      'payType': payType.getVal()
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return code;
  }
}
