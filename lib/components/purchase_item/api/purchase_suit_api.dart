
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/purchase_item/model/purchase_suit.dart';
import 'package:freego_flutter/http/http_tool.dart';

class PurchaseSuitApi{

  PurchaseSuitApi._internal();
  static final PurchaseSuitApi _instance = PurchaseSuitApi._internal();
  factory PurchaseSuitApi(){
    return _instance;
  }

  Future<List<PurchaseSuit>?> search({String? keyword, int pageNum = 1, int? pageSize, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/purchase_suit/search';
    List<PurchaseSuit>? list = await HttpTool.get(url, {
      'keyword': keyword,
      'pageNum': pageNum,
      'pageSize': pageSize
    }, (response){
      List<PurchaseSuit> list = [];
      for(dynamic json in response.data['data']){
        list.add(PurchaseSuit.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }
}
