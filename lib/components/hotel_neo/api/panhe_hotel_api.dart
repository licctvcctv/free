
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

class PanheHotelApi{

  PanheHotelApi._internal();
  static final PanheHotelApi _instance = PanheHotelApi._internal();
  factory PanheHotelApi(){
    return _instance;
  }

  Future<List<Hotel>?>  near({required String city, required double latitude, required double longitude, double radius = 5000, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel_neo/panhe/near';
    List<Hotel>? list = await HttpTool.get(url, {
      'cityName': city,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
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

  Future<List<Hotel>?> search({String? keyword, required String city, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel_neo/panhe/search';
    List<Hotel>? list = await HttpTool.get(url, {
      'keyword': keyword,
      'city': city,
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

  Future<Hotel?> detail({required String outerId, DateTime? startDate, DateTime? endDate, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel_neo/panhe';
    Hotel? hotel = await HttpTool.get(url, {
      'hotelId': outerId,
      'startDate': startDate?.toFormat("yyyy-MM-dd"),
      'endDate': endDate?.toFormat("yyyy-MM-dd")
    }, (response){
      return Hotel.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return hotel;
  }

  Future<List<HotelChamber>?> chamber({required String outerId, required DateTime startDate, required DateTime endDate, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel_neo/panhe/chamber';
    List<HotelChamber>? list = await HttpTool.get(url, {
      'hotelId': outerId,
      'checkInDate': startDate.toFormat("yyyy-MM-dd"),
      'checkOutDate': endDate.toFormat("yyyy-MM-dd")
    }, (response){
      List<HotelChamber> list = [];
      for(dynamic json in response.data['data']){
        list.add(HotelChamber.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<String?> order({required String outerId, required String ratePlanId, required int roomNum, required DateTime checkInDate, required DateTime checkOutDate, 
      required List<String> guestNames, required String contactName, required String contactMobile, String? contactEmail, String? remark, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel_neo/panhe/order';
    String? orderSerial = await HttpTool.post(url, {
      'hotelId': outerId,
      'ratePlanId': ratePlanId,
      'roomNum': roomNum,
      'checkInDate': checkInDate.toFormat("yyyy-MM-dd"),
      'checkOutDate': checkOutDate.toFormat("yyyy-MM-dd"),
      'guestNames': guestNames,
      'contactName': contactName,
      'contactMobile': contactMobile,
      'contactEmail': contactEmail,
      'remark': remark
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return orderSerial;
  }

  Future<String?> pay({required String orderSerial, required String payType, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel_neo/panhe/order/pay';
    String? payStr = await HttpTool.post(url, {
      'orderSerial': orderSerial,
      'payType': payType
    }, (response){
      return response.data['data'];
    });
    return payStr;
  }

  Future<bool> cancel({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel_neo/panhe/order/cancel';
    bool? result = await HttpTool.put(url, {
      'orderSerial': orderSerial,
    }, (response){
      return true;
    });
    return result ?? false;
  }

  Future<bool> refund({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel_neo/panhe/order/refund';
    bool? result = await HttpTool.post(url, {
      'orderSerial': orderSerial
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}
