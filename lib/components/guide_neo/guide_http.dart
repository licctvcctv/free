
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/guide_neo/guide_model.dart';
import 'package:freego_flutter/http/http_tool.dart';

class GuideHttp{

  GuideHttp._internal();
  static final GuideHttp _instance = GuideHttp._internal();
  factory GuideHttp(){
    return _instance;
  }

  Future<bool> create({required Guide guide, required List<GuidePoint> pointList, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/guide';
    List<dynamic> pointJsonList = [];
    for(GuidePoint point in pointList){
      pointJsonList.add(point.toJson());
    }
    bool? result = await HttpTool.post(url, {
      'guide': guide.toJson(),
      'pointList': pointJsonList
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }

  Future<List<Guide>?> search({required String keyword, int pageNum = 1, int pageSize = 10, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/guide/search';
    List<Guide>? list = await HttpTool.get(url, {
      'keyword': keyword,
      'pageNum': pageNum,
      'pageSize': pageSize
    }, (response){
      List<Guide> list = [];
      for(dynamic json in response.data['data']){
        list.add(Guide.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<Guide?> get({required int id, Function(Response)? fail, Function(Response)? success}) async{
    final String url = '/guide/$id';
    Guide? result = await HttpTool.get(url, {}, (response){
      return Guide.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return result;
  }

  Future<List<Guide>?> listByUser({required int userId, int limit = 10, int? maxId, int? minId, bool isDesc = true, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/guide/list_by_user';
    List<Guide>? list = await HttpTool.get(url, {
      'userId': userId,
      'limit': limit,
      'maxId': maxId,
      'minId': minId,
      'isDesc': isDesc
    }, (response){
      List<Guide> list = [];
      for(dynamic item in response.data['data']){
        list.add(Guide.fromJson(item));
      }
      return list;
    });
    return list;
  }
}
