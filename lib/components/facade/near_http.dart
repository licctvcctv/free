
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

class NearHttp{
  NearHttp._internal();
  static final NearHttp _instance = NearHttp._internal();
  factory NearHttp(){
    return _instance;
  }

  Future<List<Hotel>?> nearHotel({required double latitude, required double longitude, required double radius, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/near/hotel';
    List<Hotel>? result = await HttpTool.get(url, {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'pageSize': pageSize,
      'pageNum': pageNum
    }, (response) {
      List<Hotel> list = [];
      for(dynamic json in response.data['data']){
        list.add(Hotel.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return result;
  }

  Future<List<Scenic>?> nearScenic({required double latitude, required double longitude, required double radius, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/near/scenic';
    List<Scenic>? result = await HttpTool.get(url, {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'pageSize': pageSize,
      'pageNum': pageNum
    }, (response){
      List<Scenic> list = [];
      for(dynamic json in response.data['data']){
        list.add(Scenic.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return result;
  }

  Future<List<Restaurant>?> nearRestaurant({required double latitude, required double longitude, required double radius, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/near/restaurant';
    List<Restaurant>? result = await HttpTool.get(url, {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'pageSize': pageSize,
      'pageNum': pageNum
    }, (response){
      List<Restaurant> list = [];
      for(dynamic json in response.data['data']){
        list.add(Restaurant.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return result;
  }
}
