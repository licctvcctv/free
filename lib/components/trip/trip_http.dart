
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/trip/trip_common.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/util/date_time_util.dart';

class TripHttp{

  static Future<bool> createTrip({required Trip trip, List<TripPoint>? points, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/trip';
    List<Map<String, Object?>> pointMap = [];
    for(TripPoint point in points ?? []){
      pointMap.add(point.toJson());
    }
    bool? result = await HttpTool.post(url, {
      'trip': trip.toJson(),
      'points': pointMap
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }

  static Future<List<TripVo>?> getTrip({int limit = 10, int offset = 0, DateTime? startDate, DateTime? endDate, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/trip';
    List<TripVo>? list = await HttpTool.get(url, {
      'startDate': startDate != null ? DateTimeUtil.toFormat(startDate, 'yyyy-MM-dd') : null,
      'endDate': endDate != null ? DateTimeUtil.toFormat(endDate, 'yyyy-MM-dd') : null,
      'limit': limit,
      'offset': offset
    }, (response){
      List<TripVo> list = [];
      for(dynamic json in response.data['data']){
        list.add(TripVo.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  static Future<List<Trip>?> listByUser({int limit = 10, int? maxId, DateTime? timeStart, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/trip/byUser';
    List<Trip>? list = await HttpTool.get(url, {
      'limit': limit,
      'maxId': maxId,
      'timeStart': timeStart == null ? null : DateTimeUtil.toFormat(timeStart, 'yyyy-MM-dd')
    }, (response){
      List<Trip> list = [];
      for(dynamic item in response.data['data']){
        list.add(Trip.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  static Future<TripVo?> getTripById({required int id, Function(Response)? fail, Function(Response)? success}) async{
    final String url = '/trip/$id';
    TripVo? vo = await HttpTool.get(url, {}, (response){
      return TripVo.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return vo;
  }
}
