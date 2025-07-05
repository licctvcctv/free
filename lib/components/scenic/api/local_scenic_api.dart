
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:intl/intl.dart';

class LocalScenicApi{

  LocalScenicApi._internal();
  static final LocalScenicApi _instance = LocalScenicApi._internal();
  factory LocalScenicApi(){
    return _instance;
  }

  Future<Scenic?> detail(int id, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/scenic/$id';
    Scenic? scenic = await HttpTool.get(url, {}, (response){
      return Scenic.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return scenic;
  }

  Future<List<Scenic>?> near({required double latitude, required double longitude, double radius = 5000, String? city, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/near';
    List<Scenic>? list = await HttpTool.get(url, {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
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

  Future<List<Scenic>?> search({String keyword = '', required String city, int pageSize = 10, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/search';
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
    });
    return list;
  }

  Future<List<ScenicTicketPrice>?> getPriceList({required int ticketId, required DateTime startDate, required DateTime endDate}) async{
    const String url = '/scenic_ticket_price/list';
    List<ScenicTicketPrice>? list = await HttpTool.get(url, {
      'ticketId': ticketId,
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate)
    }, (response){
      List<ScenicTicketPrice> list = [];
      for(dynamic json in response.data['data']){
        list.add(ScenicTicketPrice.fromJson(json));
      }
      return list;
    });
    return list;
  }

  Future<String?> order({required int ticketId, required DateTime travelDate, required int quantity, List<OrderGuest>? guestList, required String contactName, 
  required String contactPhone, int? contactCardType, String? contactCardNo, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/order';
    List<dynamic>? guests;
    if(guestList != null){
      guests = [];
      for(OrderGuest guest in guestList){
        guests.add(guest.toJson());
      }
    }
    String? orderSerial = await HttpTool.post(url, {
      'ticketId': ticketId,
      'travelDate': travelDate.toFormat("yyyy-MM-dd"),
      'quantity': quantity,
      'guestList': guests,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactCardType': contactCardType,
      'contactCardNo': contactCardNo
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return orderSerial;
  }

  Future<String?> pay({required String orderSerial, required PayType payType, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/order/pay';
    String? payStr = await HttpTool.post(url, {
      'orderSerial': orderSerial,
      'payType': payType.getName()
    }, (response){
      return response.data['data'];
    });
    return payStr;
  }

  Future<bool> cancel({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/order/cancel';
    bool? result = await HttpTool.post(url, {
      'orderSerial': orderSerial
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }

  Future<bool> refund({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/scenic/order/refund';
    bool? result = await HttpTool.post(url, {
      'orderSerial': orderSerial
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}
