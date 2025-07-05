
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';

class UserCreditUseApi{

  UserCreditUseApi._internal();
  static final UserCreditUseApi _instance = UserCreditUseApi._internal();
  factory UserCreditUseApi(){
    return _instance;
  }

  Future<bool> buySuit({required int suitId, bool isGift = false, int? giftTo, Function(Response)? fail, Function(Response)? success}) async{
    const url = '/user_credit_use/buy_suit';
    bool? result = await HttpTool.post(url, {
      'suitId': suitId,
      'isGift': isGift,
      'giftTo': giftTo
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }

  Future<bool> buyItem({required int itemId, bool isGift = false, int? giftTo, Function(Response)? fail, Function(Response)? success}) async{
    const url = '/user_credit_use/buy_item';
    bool? result = await HttpTool.post(url, {
      'itemId': itemId,
      'isGift': isGift,
      'giftTo': giftTo
    }, (response){
      return true;
    },fail: fail, success: success);
    return result ?? false;
  }
}
