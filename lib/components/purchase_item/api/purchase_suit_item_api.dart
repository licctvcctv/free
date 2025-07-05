
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/purchase_item/model/purchase_suit_item.dart';
import 'package:freego_flutter/http/http_tool.dart';

class PurchaseSuitItemApi{

  PurchaseSuitItemApi._internal();
  static final PurchaseSuitItemApi _instance = PurchaseSuitItemApi._internal();
  factory PurchaseSuitItemApi(){
    return _instance;
  }

  Future<List<PurchaseSuitItem>?> list({required int suitId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/purchase_suit_item/list';
    List<PurchaseSuitItem>? list = await HttpTool.get(url, {
      'suitId': suitId
    }, (response){
      List<PurchaseSuitItem> list = [];
      for(dynamic json in response.data['data']){
        list.add(PurchaseSuitItem.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }
}
