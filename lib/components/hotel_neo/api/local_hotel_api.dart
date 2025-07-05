
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:intl/intl.dart';

class LocalHotelApi{

  LocalHotelApi._internal();
  static final LocalHotelApi _instance = LocalHotelApi._internal();
  factory LocalHotelApi(){
    return _instance;
  }

  Future<List<HotelChamber>?> chamber({required int hotelId, required DateTime startDate, required DateTime endDate, Function(Response)? fail, Function(Response)? success}) async{
    String url = '/hotel_neo/chamber';
    List<HotelChamber>? result = await HttpTool.get(url, {
      'hotelId': hotelId,
      'checkInDate': DateFormat('yyyy-MM-dd').format(startDate),
      'checkOutDate': DateFormat('yyyy-MM-dd').format(endDate)
    }, (response){
      List<HotelChamber> list = [];
      for(dynamic json in response.data['data']){
        list.add(HotelChamber.fromJson(json));
      }
      return list;
    });
    return result;
  }

  Future<Hotel?> detail({required int id, DateTime? startDate, DateTime? endDate, Function(Response)? fail, Function(Response)? success}) async{
    if(startDate == null){
      startDate = DateTime.now();
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    }
    endDate ??= startDate.add(const Duration(days: 1));
    const String url = '/hotel_neo/detail';
    Hotel? hotel = await HttpTool.get(url, {
      'id': id,
      'checkInDate': DateFormat('yyyy-MM-dd').format(startDate),
      'checkOutDate': DateFormat('yyyy-MM-dd').format(endDate)
    }, (response){
      return Hotel.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return hotel;
  }

  Future<List<Hotel>?> search({String keyword = '', required String city, int pageSize = 10, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel_neo/search';
    List<Hotel>? result = await HttpTool.get(url, {
      'city': city,
      'keyword': keyword,
      'pageNum': pageNum,
      'pageSize': pageSize
    }, (response){
      List<Hotel> list = [];
      for(dynamic item in response.data['data']){
        list.add(Hotel.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return result;
  }

  Future<List<Hotel>?> near({required double latitude, required double longitude, double radius = 5000, String? city, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel_neo/near';
    List<Hotel>? list = await HttpTool.get(url, {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'cityName': city,
      'pageSize': pageSize,
      'pageNum': pageNum
    }, (response){
      List<Hotel> list = [];
      for(dynamic json in response.data['data']){
        list.add(Hotel.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<String?> order({required int chamberId, required int planId, required DateTime checkInDate, required DateTime checkOutDate, required int quantity, 
  required String contactName, required String contactPhone, String? contactEmail, String? remark, Function(Response)? fail, Function(Response)? success }) async{
    const String url = '/hotel_neo/order';
    String? orderSerial = await HttpTool.post(url, {
      'chamberId': chamberId,
      'planId': planId,
      'checkInDate': checkInDate.toFormat('yyyy-MM-dd'),
      'checkOutDate': checkOutDate.toFormat('yyyy-MM-dd'),
      'quantity': quantity,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'remark': remark,
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return orderSerial;
  }

  Future<String?> pay({required String orderSerial, required PayType payType, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel_neo/order/pay';
    String? payStr = await HttpTool.post(url, {
      'orderSerial': orderSerial,
      'payType': payType.getName()
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return payStr;
  }

  Future<bool> cancel({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel_neo/cancel';
    bool? result = await HttpTool.post(url, {
      'orderSerial': orderSerial,
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return result ?? false;
  }

  Future<String?> payNew({
  required String orderNo, 
  required int payType,
  Function(Response)? fail, 
  Function(Response)? success
}) async {
  const String url = '/api/app/pay/prepay';
  String? payStr = await HttpTool.post(url, {
    'appId': 0,
    'orderNo': orderNo,
    'payType': payType
  }, (response) {
          final data = response.data['data'];
      if (payType == 5002) { // 支付宝支付
        final aliPayData = data['aliPayData'];
        final orderStr = aliPayData?['orderStr']; // 提取 orderStr
        return orderStr; // 返回 orderStr 而不是整个 data
      } else if (payType == 5001) { // 微信支付
         final wechatData = data['wechatPayData'];
      if (wechatData == null) return null;
      
      // 构建微信支付参数 Map
        final payParams = {
    'appid': 'wxc17e18662283c752',   
    //'appid': wechatData['appId'],
    'partnerid': wechatData['partnerId'],   // partnerId -> partnerid
    'prepayid': wechatData['prepayId'],     // prepayId -> prepayid
    'package': wechatData['packageData'] ?? 'Sign=WXPay',
    'noncestr': wechatData['nonceStr'],     // nonceStr -> noncestr
    'timestamp': wechatData['timeStamp'].toString(), // timeStamp -> timestamp
    'sign': wechatData['paySign'],          // 注意字段名是否一致
  };
      
      // 将 Map 转换为 JSON 字符串返回
      return json.encode(payParams);
      } 
      //return data;
    //return response.data['data'];
  }, fail: fail, success: success);
  return payStr;
}

Future<String?> createOrder({
  required int orderType, // 酒店为2
  required int price, // 价格(分)
  required int chamberId,
  required DateTime checkInDate,
  required DateTime checkOutDate,
  required String contactEmail,
  required String contactName,
  required String contactPhone,
  required int planId,
  required int quantity,
  String? remark,
  required int userId, // 商户ID
  Function(Response)? fail,
  Function(Response)? success
}) async {
  const String url = '/api/app/pay/createOrder';
  String? orderNo = await HttpTool.post(url, {
    'discounts': 0, // 固定为0
    'orderType': orderType, // 酒店为2
    'price': price, // 价格(分)
    'userId': userId, // 商户ID
    'chamberId': chamberId,
    'checkInDate': DateFormat('yyyy-MM-dd').format(checkInDate), // 修正日期格式转换
    'checkOutDate': DateFormat('yyyy-MM-dd').format(checkOutDate), 
    'contactEmail': contactEmail,
    'contactName': contactName,
    'contactPhone': contactPhone,
    'planId': planId,
    'quantity': quantity,
    if (remark != null) 'remark': remark,
  }, (response) {
    return response.data['data']?['orderNo']; // 假设返回数据中有orderNo字段
  }, fail: fail, success: success);
  return orderNo;
}

Future<Map<String, dynamic>?> checkPayStatus({
  required String orderNo,
  Function(Response)? fail,
  Function(Response)? success,
}) async {
  const String url = '/api/app/pay/payComplete';
  Map<String, dynamic>? payStatus = await HttpTool.post(url, {
    'orderNo': orderNo,
  }, (response) {
    return response.data; // 返回完整的 data 部分
  }, fail: fail, success: success);
  return payStatus;
}
}
