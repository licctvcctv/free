
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/product_neo/product_source.dart';
import 'package:freego_flutter/components/scenic/api/local_scenic_api.dart';
import 'package:freego_flutter/components/scenic/api/panhe_scenic_api.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';

class ScenicApi{

  ScenicApi._internal();
  static final ScenicApi _instance = ScenicApi._internal();
  factory ScenicApi(){
    return _instance;
  }

  Future<List<Scenic>?> search({String? keyword, String? city, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    return PanheScenicApi().search(keyword: keyword, city: city, pageSize: pageSize, pageNum: pageNum, fail: fail, success: success);
  }

  Future<List<Scenic>?> near({String? cityName, required double latitude, required double longitude, double radius = 5000, int pageSize = 20, int pageNum = 1, Function(Response)? fail, Function(Response)? success}) async{
    return await PanheScenicApi().near(cityName: cityName, latitude: latitude, longitude: longitude, radius: radius, pageSize: pageSize, pageNum: pageNum, fail: fail, success: success);
  }

  Future<Scenic?> detail({int? id, String? outerId, String? source, Function(Response)? fail, Function(Response)? success}) async{
    if(id != null){
      return LocalScenicApi().detail(id, fail: fail, success: success);
    }
    ProductSource? productSource;
    if(source != null){
      productSource = ProductSourceExt.getSource(source);
    }
    if(outerId == null || productSource == null){
      return null;
    }
    if(productSource == ProductSource.panhe){
      return PanheScenicApi().detail(outerId: outerId, fail: fail, success: success);
    }
    return null;
  }

  Future<bool> cancel({required OrderNeo order, Function(Response)? fail, Function(Response)? success}) async{
    if(order.orderSerial == null){
      return false;
    }
    ProductSource? productSource;
    if(order.source != null){
      productSource = ProductSourceExt.getSource(order.source!);
    }
    if(productSource == ProductSource.local){
      return LocalScenicApi().cancel(orderSerial: order.orderSerial!, fail: fail, success: success);
    }
    else if(productSource == ProductSource.panhe){
      return PanheScenicApi().cancel(orderSerial: order.orderSerial!, fail: fail, success: success);
    }
    return false;
  }
}