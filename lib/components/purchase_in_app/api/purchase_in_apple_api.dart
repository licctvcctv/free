
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/purchase_in_app/model/purchase_in_apple.dart';
import 'package:freego_flutter/http/http_tool.dart';

class PurchaseInAppleApi{

  PurchaseInAppleApi._internal();
  static final PurchaseInAppleApi _instance = PurchaseInAppleApi._internal();
  factory PurchaseInAppleApi(){
    return _instance;
  }

  Future<List<PurchaseInApple>?> range({String? keyword, int? minVal, int? maxVal, int? limit, bool isDesc = false, Function(Response)? fail, Function(Response)? success}) async{
    const url = '/purchase_in_apple/range';
    List<PurchaseInApple>? list = await HttpTool.get(url, {
      'keyword': keyword,
      'minVal': minVal,
      'maxVal': maxVal,
      'limit': limit,
      'isDesc': isDesc
    }, (response){
      List<PurchaseInApple> list = [];
      for(dynamic json in response.data['data']){
        list.add(PurchaseInApple.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<bool> verify({required String receipt, Function(Response)? fail, Function(Response)? success}) async{
    const url = '/purchase_in_apple/verify';
    bool? result = await HttpTool.post(url, {
      'receipt': receipt
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}
