
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:intl/intl.dart';

class PanheHotel{

  PanheHotel._internal();
  static final PanheHotel _instance = PanheHotel._internal();
  factory PanheHotel(){
    return _instance;
  }

  Future<List<Hotel>?> nearHotel({required double latitude, required double longitude, required double radius, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/hotel_neo/panhe/near';
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

  Future<Hotel?> getHotel({required int id, DateTime? startDate, DateTime? endDate, Function(Response)? fail, Function(Response)? success}) async{
    String url = '/hotel_neo/panhe/$id';
    Hotel? hotel = await HttpTool.get(url, {
      'startDate': startDate == null ? null : DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': endDate == null ? null : DateFormat('yyyy-MM-dd').format(endDate)
    }, (response){
      return Hotel.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return hotel;
  }

}
