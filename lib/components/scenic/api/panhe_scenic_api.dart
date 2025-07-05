
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

class PanheScenicApi{

  PanheScenicApi._internal();
  static final PanheScenicApi _instance = PanheScenicApi._internal();
  factory PanheScenicApi(){
    return _instance;
  }

  Future<List<Scenic>?> near({String? cityName, required double latitude, required double longitude, double radius = 5000, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/panhe/near';
    List<Scenic>? list = await HttpTool.get(url, {
      'cityName': cityName,
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
    return list;
  }

  Future<List<Scenic>?> search({String? keyword, String? city, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/panhe/search';
    List<Scenic>? list = await HttpTool.get(url, {
      'keyword': keyword,
      'city': city,
      'pageSize': pageSize,
      'pageNum': pageNum
    }, (response){
      List<Scenic> list = [];
      for(dynamic json in response.data['data']){
        list.add(Scenic.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<Scenic?> detail({required String outerId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/panhe';
    Scenic? scenic = await HttpTool.get(url, {
      'scenicId': outerId
    }, (response){
      return Scenic.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return scenic;
  }

  Future<ScenicTicket?> ticket({required String outerId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/panhe/ticket';
    ScenicTicket? ticket = await HttpTool.get(url, {
      'ticketId': outerId
    }, (response){
      return ScenicTicket.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return ticket;
  }

  Future<String?> order({required String scenicId, required String ticketId, required int quantity, required DateTime travelDate, 
  List<OrderGuest>? orderGuest, required String contactName, required String contactPhone, int? contactCardType, String? contactCardNo, 
  Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/panhe/order';
    List<Map<String, Object?>>? guests;
    if(orderGuest != null){
      guests = [];
      for(OrderGuest guest in orderGuest){
        guests.add(guest.toJson());
      }
    }
    String? orderSerial = await HttpTool.post(url, {
      'scenicId': scenicId,
      'ticketId': ticketId,
      'quantity': quantity,
      'travelDate': travelDate.toFormat('yyyy-MM-dd'),
      'orderGuest': guests,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactCardType': contactCardType,
      'contactCardNo': contactCardNo
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return orderSerial;
  }

  Future<String?> pay({required String orderSerial, required String payType, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/panhe/order/pay';
    String? payStr = await HttpTool.post(url, {
      'orderSerial': orderSerial,
      'payType': payType
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return payStr;
  }

  Future<bool> refund({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/panhe/order/refund';
    bool? result = await HttpTool.post(url, {
      'orderSerial': orderSerial
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }

  Future<bool> cancel({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/panhe/order/cancel';
    bool? result = await HttpTool.put(url, {
      'orderSerial': orderSerial
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}
