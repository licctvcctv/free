
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/model/hotel.dart';
import 'package:freego_flutter/model/order.dart';
import 'package:freego_flutter/model/order_customer.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/pager.dart';

class HotelBookParam{
  int roomId;
  DateTime startDate;
  DateTime leaveDate;
  int bookNum;
  List<OrderCustomer> customerList;
  HotelBookParam({required this.roomId, required this.startDate, required this.leaveDate, required this.bookNum, required this.customerList});
}

class HttpHotel{

  static Future<Order?> book(HotelBookParam param, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel/book';
    List<Map<String, dynamic>> customerMap = [];
    for(OrderCustomer item in param.customerList){
      customerMap.add(item.toJson());
    }
    Order? order = await HttpTool.post(url, {
      'roomId': param.roomId,
      'startDate': DateTimeUtil.toYMD(param.startDate),
      'endDate': DateTimeUtil.toYMD(param.leaveDate),
      'bookNum': param.bookNum,
      'customerList': customerMap
    }, (response){
      Order order = Order.fromJson(response.data['data']);
      return order;
    }, fail: fail, success: success);
    return order;
  }

  static Future<Pager<Hotel>?> searchHotel(String? keyword, {int limit = 10, int offset = 0, DateTime? endTime, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel/search';
    Pager<Hotel>? pager = await HttpTool.get(url, {
      'keyword': keyword,
      'limit': limit, 
      'offset': offset,
      'endTime': endTime?.toFormat('yyyy-MM-dd HH:mm:ss')
    }, (response){
      List<Hotel> list = [];
      for(dynamic item in response.data['data']['list']){
        list.add(Hotel.fromJson(item));
      }
      return Pager(list, response.data['data']['total']);
    }, fail: fail, success: success);
    return pager;
  }

  static Future<Hotel?> getDetail(int hotelId, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel/detail';
    Hotel? hotel = await HttpTool.get(url, {
      'id': hotelId
    }, (response){
      Hotel hotel = Hotel.fromJson(response.data['data']);
      return hotel;
    }, fail: fail, success: success);
    return hotel;
  }

  static Future<List<HotelRoomPrice>?> getPrice(int roomId, DateTime startDay, DateTime endDay, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel/getRangePrice';
    List<HotelRoomPrice>? list = await HttpTool.get(url, {
      'roomId': roomId,
      'startDay': DateTimeUtil.toYMD(startDay),
      'endDay': DateTimeUtil.toYMD(endDay)
    }, (response){
      List<HotelRoomPrice> list = [];
      for(dynamic item in response.data['data']){
        list.add(HotelRoomPrice.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

}
