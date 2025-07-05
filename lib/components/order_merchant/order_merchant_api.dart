
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

class OrderMerchantHttp{

  OrderMerchantHttp._internal();
  static final OrderMerchantHttp _instance = OrderMerchantHttp._internal();
  factory OrderMerchantHttp(){
    return _instance;
  }

  Future<OrderHotel?> getOrderHotel({required int orderId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/merchant/order/detail/hotel';
    OrderHotel? order = await HttpTool.get(url, {
      'id': orderId
    }, (response){
      return OrderHotel.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return order;
  }

  Future<OrderScenic?> getOrderScenic({required int orderId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/merchant/order/detail/scenic';
    OrderScenic? order = await HttpTool.get(url, {
      'id': orderId
    }, (response) {
      return OrderScenic.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return order;
  }
  
  Future<OrderRestaurant?> getOrderRestaurant({required int orderId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/merchant/order/detail/restaurant';
    OrderRestaurant? order = await HttpTool.get(url, {
      'id': orderId
    }, (response) {
      return OrderRestaurant.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return order;
  }

  Future<OrderTravel?> getOrderTravel({required int orderId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/merchant/order/detail/travel';
    OrderTravel? order = await HttpTool.get(url, {
      'id': orderId
    }, (response) {
      return OrderTravel.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return order;
  }

  Future<bool> confirmOrder({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/order_neo/state/confirm';
    bool? result = await HttpTool.put(url, {
      'orderSerial': orderSerial
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }

  Future<bool> rejectOrder({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/order_neo/state/reject';
    bool? result = await HttpTool.put(url, {
      'orderSerial': orderSerial
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }

  Future<bool> servicingOrder({required String orderSerail, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/order_neo/state/servicing';
    bool? result = await HttpTool.put(url, {
      'orderSerial': orderSerail
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}
