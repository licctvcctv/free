
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

class RestaurantApi{

  RestaurantApi._internal();
  static final RestaurantApi _instance = RestaurantApi._internal();
  factory RestaurantApi(){
    return _instance;
  }

  Future<List<Restaurant>?> search({String keyword = '', required String city, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/restaurant/search';
    List<Restaurant>? pager = await HttpTool.get(url, {
      'city': city,
      'keyword': keyword,
      'pageNum': pageNum,
      'pageSize': pageSize
    }, (response){
      List<Restaurant> list = [];
      for(dynamic item in response.data['data']){
        list.add(Restaurant.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return pager;
  }

  Future<List<Restaurant>?> near({required double latitude, required double longitude, double radius = 5000, String? city, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/restaurant/near';
    List<Restaurant>? list = await HttpTool.get(url, {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'city': city,
      'pageSize': pageSize,
      'pageNum': pageNum
    }, (response){
      List<Restaurant> list = [];
      for(dynamic json in response.data['data']){
        list.add(Restaurant.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<Restaurant?> getById(int id, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/restaurant/detail';
    Restaurant? result = await HttpTool.get(url, {
      'id': id
    }, (response){
      return Restaurant.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return result;
  }

  Future<String?> order({required int restaurantId, required int numberOfPeople, required DateTime diningTime, required DiningType diningType, required String contactName, 
  required String contactPhone, String? remark, required List<OrderRestaurantDishParam> dishList, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/restaurant/order';
    List<dynamic> dishes = [];
    for(OrderRestaurantDishParam param in dishList){
      dishes.add(param.toJson());
    }
    String? orderSerial = await HttpTool.post(url, {
      'restaurantId': restaurantId,
      'numberOfPeople': numberOfPeople,
      'diningTime': diningTime.toFormat('yyyy-MM-dd HH:mm'),
      'diningType': diningType.getText(),
      'contactName': contactName,
      'contactPhone': contactPhone,
      'remark': remark,
      'dishes': dishes
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return orderSerial;
  }

  Future<String?> pay({required String orderSerial, required PayType payType, Function(Response)? fail, Function(Response)? success}) async{
    const String url ='/restaurant/order/pay';
    String? payStr = await HttpTool.post(url, {
      'orderSerial': orderSerial,
      'payType': payType.getName()
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return payStr;
  }

  Future<bool> cancel({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/restaurant/order/cancel';
    bool? result = await HttpTool.post(url, {
      'orderSerial': orderSerial
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}

class OrderRestaurantDishParam{
  int? dishId;
  int? quantity;

  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['dishId'] = dishId;
    map['quantity'] = quantity;
    return map;
  }
}
