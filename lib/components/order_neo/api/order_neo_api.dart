

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:freego_flutter/components/hotel_neo/api/panhe_hotel_api.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_neo/product_source.dart';
import 'package:freego_flutter/components/scenic/api/panhe_scenic_api.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:intl/intl.dart';

class OrderNeoApi{

  OrderNeoApi._internal();
  static final OrderNeoApi _instance = OrderNeoApi._internal();
  factory OrderNeoApi(){
    return _instance;
  }

  Future<String?> bookScenicFromFreego({
    required int ticketId,
    required DateTime tourDate,
    required int quantity,
    required List<OrderGuest> guestList,
    String? contactName,
    String? contactPhone,
    int? contactCardType,
    String? contactCardNo,
    Function(Response)? fail,
    Function(Response)? success,
  }) async{
    const String url = '/order_neo/scenic/freego';
    List<Map<String, Object?>> guestJsonList = [];
    for(OrderGuest guest in guestList){
      guestJsonList.add(guest.toJson());
    }
    String? result = await HttpTool.post(url, {
      'ticketId': ticketId,
      'tourDate': DateFormat('yyyy-MM-dd').format(tourDate),
      'quantity': quantity,
      'guestList': guestJsonList,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactCardType': contactCardType,
      'contactCardNo': contactCardNo,
    }, (response){
      String? result = response.data['data'];
      return result;
    }, fail: fail, success: success);
    return result;
  }

  Future<String?> bookHotelFromFreego({
    required int chamberId,
    required int planId,
    required DateTime startDate,
    required DateTime endDate,
    required int quantity,
    String? contactName,
    required String contactPhone,
    String? contactEmail,
    String? remark,
    Function(Response)? fail,
    Function(Response)? success
  }) async{
    const String url = '/order_neo/hotel/freego';
    String? result = await HttpTool.post(url, {
      'chamberId': chamberId,
      'planId': planId,
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
      'quantity': quantity,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'remark': remark
    }, (response){
      String? result = response.data['data'];
      return result;
    }, fail: fail, success: success);
    return result;
  }

  Future<String?> bookRestaurantFromFreego({
    required int restaurantId,
    required int quantity,
    required DateTime selectedTime,
    required int diningMethods,
    String? contactName,
    required String contactPhone,
    required String remark,
    List<int>? selectedDishes,  // Added parameter for selected dishes
    Map<int, int>? dishQuantities,  // Added parameter for dish quantities
    Function(Response)? fail,
    Function(Response)? success,
  }) async {
    const String url = '/order_neo/restaurant/freego';

    // Construct a list of dish objects with their IDs and quantities
    List<Map<String, dynamic>> dishList = [];
    if (selectedDishes != null && dishQuantities != null) {
      for (int dishId in selectedDishes) {
        int quantity = dishQuantities[dishId] ?? 0;
        dishList.add({'dishId': dishId, 'quantity': quantity});
      }
    }

    String? result = await HttpTool.post(url, {
      'restaurantId': restaurantId,
      'quantity': quantity,
      'selectedTime': DateFormat('yyyy-MM-dd HH:mm').format(selectedTime),
      'diningMethods': diningMethods,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'remark': remark,
      'dishes': dishList,  // Include the dish list in the request
    }, (response) {
      String? result = response.data['data'];
      return result;
    }, fail: fail, success: success);

    return result;
  }

  Future<String?> bookTravelFromFreego({
    required int travelId,
    required int travelSuitId,
    required String travelName,
    required String travelSuitName,
    required int number,
    required int oldNumber,
    required int childNumber,
    required DateTime startDate,
    required DateTime endDate,
    required String contactName,
    required String contactPhone,
    required String contactEmail,
    required String emergencyName,
    required String emergencyPhone,
    required String remark,
    required List<Map<String, dynamic>> savedGuestInfoList,
    Function(Response)? fail,
    Function(Response)? success,

  }) async {
    const String url = '/order_neo/travel/freego';

    List<Map<String, dynamic>> dishList = [];
    String? result = await HttpTool.post(url, {
      'travelId': travelId,
      'travelSuitId': travelSuitId,
      'travelName': travelName,
      'travelSuitName': travelSuitName,
      'number': number,
      'oldNumber': oldNumber,
      'childNumber': childNumber,
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'emergencyName': emergencyName,
      'emergencyPhone': emergencyPhone,
      'remark': remark,
      'savedGuestInfoList': savedGuestInfoList,
    }, (response) {
      String? result = response.data['data'];
      return result;
    }, fail: fail, success: success);

    return result;
  }

  Future<List<OrderNeo>?> listNewOrder({int? minId, int limit = 10, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/order_neo/list';
    List<OrderNeo>? result = await HttpTool.get(url, {
      'minId': minId,
      'limit': limit,
    }, (response){
      List<OrderNeo> list = [];
      for(dynamic json in response.data['data']){
        OrderNeo? order = OrderNeoConverter().convert(json);
        if(order != null){
          list.add(order);
        }
      }
      list.sort((a, b){
        if(b.id == null){
          return 1;
        }
        if(a.id == null){
          return -1;
        }
        return b.id!.compareTo(a.id!);
      });
      return list;
    });
    return result;
  }

  Future<List<OrderNeo>?> listHistoryOrder({int? maxId, int limit = 10, DateTime? startTime, DateTime? endTime, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/order_neo/list';
    List<OrderNeo>? result = await HttpTool.get(url, {
      'maxId': maxId,
      'limit': limit,
      'startTime': startTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime) : null,
      'endTime': endTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(endTime) : null
    }, (response){
      List<OrderNeo> list = [];
      for(dynamic json in response.data['data']){
        OrderNeo? order = OrderNeoConverter().convert(json);
        if(order != null){
          list.add(order);
        }
      }
      list.sort((a, b){
        if(b.id == null){
          return 1;
        }
        if(a.id == null){
          return -1;
        }
        return b.id!.compareTo(a.id!);
      });
      return list;
    });
    return result;
  }

  Future<OrderHotel?> getOrderHotel({required int id, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/order_neo/detail/hotel';
    OrderHotel? order = await HttpTool.get(url, {
      'id': id
    }, (response){
      return OrderHotel.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return order;
  }

  Future<OrderScenic?> getOrderScenic({required int id, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/order_neo/detail/scenic';
    OrderScenic? order = await HttpTool.get(url, {
      'id': id
    }, (response){
      return OrderScenic.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return order;
  }

  Future<OrderRestaurant?> getOrderRestaurant({required int id, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/order_neo/detail/restaurant';
    OrderRestaurant? order = await HttpTool.get(url, {
      'id': id
    }, (response){
      return OrderRestaurant.fromJson(response.data['data']);
    });
    return order;
  }

  Future<OrderTravel?> getOrderTravel({required int id, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/order_neo/detail/travel';
    OrderTravel? order = await HttpTool.get(url, {
      'id': id
    }, (response){
      return OrderTravel.fromJson(response.data['data']);
    });
    return order;
  }
  
  Future<bool> refundOrder({
    required String orderNo,
    int appId = 0,
    Function(Response)? fail,
    Function(Response)? success,
  }) async {
    const String url = '/api/app/pay/refund';
    bool? result = await HttpTool.post(
      url,
      {
        'appId': appId,
        'orderNo': orderNo,
      },
      (response) {
        // 打印完整的接口返回值
        print('接口返回值: ${response.data}');
      
        // 根据接口规范，code为0表示成功
        return response.data['code'] == 10200;
      },
      fail: fail,
      success: success,
    );
    return result ?? false;
  }
  
  Future<bool> refund({required String orderSerial, required ProductType orderType, String? source, Function(Response)? fail, Function(Response)? success}) async{
    ProductSource? productSource;
    if(source != null){
      productSource = ProductSourceExt.getSource(source);
    }
    if(productSource == null){
      return false;
    }
    if(productSource == ProductSource.panhe){
      switch(orderType){
        case ProductType.hotel:
          return PanheHotelApi().refund(orderSerial: orderSerial, fail: fail, success: success);
        case ProductType.scenic:
          return PanheScenicApi().refund(orderSerial: orderSerial, fail: fail, success: success);
        default:  
          return false;
      }
    }
    return false;
  }
}

class OrderNeoConverter{

  OrderNeoConverter._internal();
  static final OrderNeoConverter _instance = OrderNeoConverter._internal();
  factory OrderNeoConverter(){
    return _instance;
  }

  OrderNeo? convert(dynamic json){
    int? orderType = json['orderType'];
    if(orderType == null){
      return null;
    }
    ProductType? productType = ProductTypeExt.getType(orderType);
    if(productType == null){
      return null;
    }
    switch(productType){
      case ProductType.hotel:
        return OrderHotel.fromJson(json);
      case ProductType.scenic:
        return OrderScenic.fromJson(json);
      case ProductType.restaurant:
        return OrderRestaurant.fromJson(json);
      case ProductType.travel :
        return OrderTravel .fromJson(json);
      default:
        return null;
    }
  }
}
            
Future<List<OrderRestaurantDish>?> getRestaurantDish({required int orderId, Function(Response)? fail, Function(Response)? success}) async {
  const String url = '/order_neo/restaurantDish';
  List<OrderRestaurantDish>? result = await HttpTool.get(url, {
    'orderId': orderId,
  }, (response) {
    List<OrderRestaurantDish> restaurantDish = [];
    for (dynamic json in response.data['data']) {
      OrderRestaurantDish? dish = OrderRestaurantDish.fromJson(json);
      if (dish != null) {
        restaurantDish.add(dish);
      }
    }
    return restaurantDish;
  }, fail: fail, success: success);
  return result;
}
