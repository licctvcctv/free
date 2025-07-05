
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/travel/travel_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

class TravelApi{

  TravelApi._internal();
  static final TravelApi _instance = TravelApi._internal();
  factory TravelApi(){
    return _instance;
  }

  Future<List<Travel>?> search({String keyword = '', required String city, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/travel/search';
    List<Travel>? pager = await HttpTool.get(url, {
      'city': city,
      'keyword': keyword,
      'pageNum': pageNum,
      'pageSize': pageSize
    }, (response){
      List<Travel> list = [];
      for(dynamic item in response.data['data']){
        list.add(Travel.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return pager;
  }

  Future<Travel?> getById({required int travelId, DateTime? day,  Function(Response)? fail, Function(Response)? success}) async{
    day ??= DateTime.now();
    const String url = '/travel/detail';
    Travel? result = await HttpTool.get(url, {
      'id': travelId,
      'day': day.toFormat('yyyy-MM-dd')
    }, (response){
      return Travel.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return result;
  }

  Future<List<TravelSuit>?> suits({required int travelId, DateTime? day, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/travel/suits';
    List<TravelSuit>? list = await HttpTool.get(url, {
      'travelId': travelId,
      'day': day?.toFormat('yyyy-MM-dd')
    }, (response){
      List<TravelSuit> list = [];
      for(dynamic json in response.data['data']){
        list.add(TravelSuit.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<List<TravelSuitPrice>?> suitPrices({required int suitId, required DateTime startDate, required DateTime endDate, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/travel/suit/price';
    List<TravelSuitPrice>? list = await HttpTool.get(url, {
      'suitId': suitId,
      'startDate': startDate.toFormat('yyyy-MM-dd'),
      'endDate': endDate.toFormat('yyyy-MM-dd')
    }, (response){
      List<TravelSuitPrice> list = [];
      for(dynamic json in response.data['data']){
        list.add(TravelSuitPrice.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<String?> order({required int travelId, required int travelSuitId, required int number, required int oldNumber, required int childNumber, 
  required DateTime startDate, required String contactName, required String contactPhone, String? contactEmail, 
  required String emergencyName, required String emergencyPhone, String? remark, required List<OrderGuest> guestList, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/travel/order';
    List<dynamic> guests = [];
    for(OrderGuest guest in guestList){
      guests.add(guest.toJson());
    }
    String? orderSerial = await HttpTool.post(url, {
      'travelId': travelId,
      'travelSuitId': travelSuitId,
      'number': number,
      'oldNumber': oldNumber,
      'childNumber': childNumber,
      'startDate': startDate.toFormat('yyyy-MM-dd'),
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'emergencyName': emergencyName,
      'emergencyPhone': emergencyPhone,
      'remark': remark,
      'guestList': guests
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return orderSerial;
  }

  Future<String?> pay({required String orderSerial, required PayType payType, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/travel/order/pay';
    String? payStr = await HttpTool.post(url, {
      'orderSerial': orderSerial,
      'payType': payType.getName()
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return payStr;
  }

  Future<bool> cancel({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/travel/order/cancel';
    bool? result = await HttpTool.post(url, {
      'orderSerial': orderSerial
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }

  Future<bool> refund({required String orderSerial, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/travel/order/refund';
    bool? result = await HttpTool.post(url, {
      'orderSerial': orderSerial
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}
