
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:freego_flutter/components/purchase_item/model/user_purchase_item.dart';
import 'package:freego_flutter/http/http_tool.dart';

class UserPurchaseItemApi{

  UserPurchaseItemApi._internal();
  static final UserPurchaseItemApi _instance = UserPurchaseItemApi._internal();
  factory UserPurchaseItemApi(){
    return _instance;
  }

  Future<List<UserPurchaseItem>?> list({int pageNum = 1, int? pageSize, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user_purchase_item/list';
    List<UserPurchaseItem>? list = await HttpTool.get(url, {
      'pageNum': pageNum,
      'pageSize': pageSize
    }, (response){
      List<UserPurchaseItem> list = [];
      for(dynamic json in response.data['data']){
        list.add(UserPurchaseItem.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<List<UserPurchaseItem>?> search({required List<String> effectBeans, int pageNum = 1, int? pageSize, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user_purchase_item/search';
    List<UserPurchaseItem>? list = await HttpTool.get(url, {
      'effectBeans': effectBeans,
      'pageNum': pageNum,
      'pageSize': pageSize
    }, (response){
      List<UserPurchaseItem> list = [];
      for(dynamic json in response.data['data']){
        list.add(UserPurchaseItem.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<bool> use({required int itemId, required int count, required String effectBean, dynamic extra, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user_purchase_item/use';
    bool? result = await HttpTool.put(url, {
      'itemId': itemId,
      'count': count,
      'effectBean': effectBean,
      'extra': json.encoder.convert(extra)
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false; 
  }
}
