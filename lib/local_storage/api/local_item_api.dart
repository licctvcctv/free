
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/local_storage/model/local_item.dart';

class LocalItemApi{

  LocalItemApi._internal();
  static final LocalItemApi _instance = LocalItemApi._internal();
  factory LocalItemApi(){
    return _instance;
  }

  Future<List<LocalItem>?> listSimple({required List<int> ids, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/purchase_item_type/simple_item/list';
    List<LocalItem>? list = await HttpTool.post(url, {
      'ids': ids
    }, (response){
      List<LocalItem> list = [];
      DateTime now = DateTime.now();
      for(dynamic json in response.data['data']){
        LocalItem item = LocalItem.fromJson(json);
        item.lastUpdateTime = now;
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<LocalItem?> getSimple({required int id, Function(Response)? fail, Function(Response)? success}) async{
    String url = '/purchase_item_type/simple_item/$id';
    LocalItem? item = await HttpTool.get(url, {}, (response){
      LocalItem item = LocalItem.fromJson(response.data['data']);
      item.lastUpdateTime = DateTime.now();
      return item;
    }, fail: fail, success: success);
    return item;
  }
}
