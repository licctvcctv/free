
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/util/pager.dart';

class HttpRestaurant{

  static Future<Pager<Restaurant>?> search(String? keyword, {int limit = 10, int offset = 0, DateTime? endTime, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/restaurant/search';
    Pager<Restaurant>? pager = await HttpTool.get(url, {
      'keyword': keyword,
      'limit': limit,
      'offset': offset,
      'endTime': endTime
    }, (response){
      List<Restaurant> list = [];
      for(dynamic item in response.data['data']['list']){
        list.add(Restaurant.fromJson(item));
      }
      return Pager(list, response.data['data']['total']);
    }, fail: fail, success: success);
    return pager;
  }

  static Future<Restaurant?> getById(int id, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/restaurant/detail';
    Restaurant? result = await HttpTool.get(url, {
      'id': id
    }, (response){
      return Restaurant.fromJson(response.data['data']);
    });
    return result;
  }
}
