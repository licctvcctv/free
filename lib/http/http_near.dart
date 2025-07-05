
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/model/circle.dart';
import 'package:freego_flutter/model/guide.dart';
import 'package:freego_flutter/model/hotel.dart';
import 'package:freego_flutter/model/spot.dart';

class HttpNear{

  static Future<List<Hotel>?> nearHotel(double lat, double lng, {double? radius, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/near/hotel';
    List<Hotel>? list = await HttpTool.get(url, {
      'lat': lat,
      'lng': lng,
      'radius': radius
    }, (response){
      List<Hotel> list = [];
      for(dynamic item in response.data['data']){
        list.add(Hotel.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  static Future<List<SpotModel>?> nearSpot(double lat, double lng, {double? radius, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/near/spot';
    List<SpotModel>? list = await HttpTool.get(url, {
      'lat': lat,
      'lng': lng,
      'radius': radius
    }, (response){
      List<SpotModel> list = [];
      for(dynamic item in response.data['data']){
        list.add(SpotModel.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  static Future<List<Restaurant>?> nearRestaurant(double lat, double lng, {double? radius, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/near/restaurant';
    List<Restaurant>? list = await HttpTool.get(url, {
      'lat': lat,
      'lng': lng,
      'radius': radius
    }, (response){
      List<Restaurant> list = [];
      for(dynamic item in response.data['data']){
        list.add(Restaurant.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  static Future<List<GuideModel>?> nearGuide(double lat, double lng, {double? radius, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/near/guide';
    List<GuideModel>? list = await HttpTool.get(url, {
      'lat': lat,
      'lng': lng,
      'radius': radius
    }, (response){
      List<GuideModel> list = [];
      for(dynamic item in response.data['data']){
        list.add(GuideModel.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  static Future<List<CircleActivityExt>?> nearCircleActivity(double lat, double lng, {double? radius, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/near/circleActivity';
    List<CircleActivityExt>? list = await HttpTool.get(url, {
      'lat': lat,
      'lng': lng,
      'radius': radius
    }, (response){
      List<CircleActivityExt> list = [];
      for(dynamic item in response.data['data']){
        list.add(CircleActivityExt.fromJson(item));
      }
      return list;
    });
    return list;
  }
}
