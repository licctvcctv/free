
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/local_storage/model/local_guide.dart';

class LocalGuideApi{

  LocalGuideApi._internal();
  static final LocalGuideApi _instance = LocalGuideApi._internal();
  factory LocalGuideApi(){
    return _instance;
  }

  Future<List<LocalGuide>?> listSimple({required List<int> ids, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/guide/simple_guide/list';
    List<LocalGuide>? list = await HttpTool.post(url, {
      'ids': ids
    }, (response){
      List<LocalGuide>? list = [];
      DateTime now = DateTime.now();
      for(dynamic json in response.data['data']){
        LocalGuide guide = LocalGuide.fromJson(json);
        guide.lastUpdateTime = now;
      }
      return list;
    });
    return list;
  }

  Future<LocalGuide?> getSimple({required int id, Function(Response)? fail, Function(Response)? success}) async{
    String url = '/guide/simple_guide/$id';
    LocalGuide? guide = await HttpTool.get(url, {}, (response){
      LocalGuide guide = LocalGuide.fromJson(response.data['data']);
      guide.lastUpdateTime = DateTime.now();
      return guide;
    });
    return guide;
  }
}