
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/hotel_neo/api/local_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/api/panhe_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/product_neo/product_source.dart';

class HotelApi{

  HotelApi._internal();
  static final HotelApi _instance = HotelApi._internal();
  factory HotelApi(){
    return _instance;
  }

  Future<List<Hotel>?> near({required String city, required double latitude, required double longitude, double radius = 5000, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    return await PanheHotelApi().near(city: city, latitude: latitude, longitude: longitude, radius: radius, pageSize: pageSize, pageNum: pageNum, fail: fail, success: success);
  }

  Future<List<Hotel>?> search({String? keyword, required String city, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    return PanheHotelApi().search(keyword: keyword, city: city, pageSize: pageSize, pageNum: pageNum, fail: fail, success: success);
  }

  Future<Hotel?> detail({int? id, String? outerId, String? source, DateTime? startDate, DateTime? endDate, Function(Response)? fail, Function(Response)? success}) async{
    if(outerId != null && outerId!.isNotEmpty && source != null){
      ProductSource? productSource;
      productSource = ProductSourceExt.getSource(source);
      if(productSource == ProductSource.panhe){
        return PanheHotelApi().detail(outerId: outerId, startDate: startDate, endDate: endDate, fail: fail, success: success);
      }
      return null;
    }
    if(id != null){
      return LocalHotelApi().detail(id: id, startDate: startDate, endDate: endDate, fail: fail, success: success);
    }
    return null;
  }

  Future<List<HotelChamber>?> chamber({int? id, String? outerId, String? source, required DateTime startDate, required DateTime endDate, Function(Response)? fail, Function(Response)? success}) async{
    if(outerId != null && source != null){
      ProductSource? productSource;
      productSource = ProductSourceExt.getSource(source);
      if(productSource == ProductSource.panhe){
        return PanheHotelApi().chamber(outerId: outerId, startDate: startDate, endDate: endDate, fail: fail, success: success);
      }
      return null;
    }
    if(id != null){
      return LocalHotelApi().chamber(hotelId: id, startDate: startDate, endDate: endDate, fail: fail, success: success);
    }
    return null;
  }

  Future<bool> cancel({required OrderNeo order, Function(Response)? fail, Function(Response)? success}) async{
    if(order.orderSerial == null){
      return false;
    }
    ProductSource? productSoruce;
    if(order.source != null){
      productSoruce = ProductSourceExt.getSource(order.source!);
    }
    if(productSoruce == ProductSource.local){
      return LocalHotelApi().cancel(orderSerial: order.orderSerial!, fail: fail, success: success);
    }
    else if(productSoruce == ProductSource.panhe){
      return PanheHotelApi().cancel(orderSerial: order.orderSerial!, fail: fail, success: success);
    }
    return false;
  }
}
