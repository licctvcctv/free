
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/components/circle_neo/circle_util.dart';
import 'package:freego_flutter/http/http_tool.dart';

class CircleHttp{

  CircleHttp._internal();
  static final CircleHttp _instance = CircleHttp._internal();
  factory CircleHttp(){
    return _instance;
  }

  Future<List<Circle>?> getHistoryCircle({required String city, String keyword = '', int? userId, int? maxId, int limit = 10}) async{
    const String url = '/circle/list';
    List<Circle>? list = await HttpTool.get(url, {
      'city': city,
      'keyword': keyword,
      'userId': userId,
      'maxId': maxId,
      'isDesc': true,
      'limit': limit
    }, (response){
      List<Circle> list = [];
      for(dynamic json in response.data['data']){
        Circle? circle = CircleConverter().convert(json);
        if(circle != null){
          list.add(circle);
        }
      }
      list.sort((a, b) {
        if(a.id == null){
          return 1;
        }
        if(b.id == null){
          return -1;
        }
        if(a.id! <= b.id!){
          return 1;
        }
        return -1;
      });
      return list;
    });
    return list;
  }

  Future<List<Circle>?> getNewCircle({required String city, String keyword = '', int? userId, int? minId, int limit = 10}) async{
    const String url = '/circle/list';
    List<Circle>? list = await HttpTool.get(url, {
      'city': city,
      'keyword': keyword,
      'userId': userId,
      'minId': minId,
      'isDesc': false,
      'limit': limit
    }, (response){
      List<Circle> list = [];
      for(dynamic json in response.data['data']){
        Circle? circle = CircleConverter().convert(json);
        if(circle != null){
          list.add(circle);
        }
      }
      list.sort((a, b) {
        if(a.id == null){
          return 1;
        }
        if(b.id == null){
          return -1;
        }
        if(a.id! <= b.id!){
          return 1;
        }
        return -1;
      });
      return list;
    });
    return list;
  }

  Future<CircleActivity?> getCircleActivity({required int id, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/circle/activity';
    CircleActivity? vo = await HttpTool.get(url, {
      'id': id
    }, (response){
      return CircleActivity.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return vo;
  }

  Future<Circle?> getCircle({required int id, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/circle';
    Circle? result = await HttpTool.get(url, {
      'id': id
    }, (response){
      Circle? result = CircleConverter().convert(response.data['data']);
      return result;
    });
    return result;
  }

  Future<List<Circle>?> listByUser({required int userId, int limit = 10, int? maxId, int? minId, bool? isDesc, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/circle/list_by_user';
    List<Circle>? list = await HttpTool.get(url, {
      'userId': userId,
      'limit': limit,
      'maxId': maxId,
      'minId': minId,
      'isDesc': isDesc,
    }, (response){
      List<Circle> list = [];
      for(dynamic item in response.data['data']){
        Circle? circle = CircleConverter().convert(item);
        if(circle != null){
          list.add(circle);
        }
      }
      list.sort((a, b) {
        if(a.id == null){
          return 1;
        }
        if(b.id == null){
          return -1;
        }
        return b.id!.compareTo(a.id!);
      });
      return list;
    });
    return list;
  }
}
