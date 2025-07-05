
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/video/video_model.dart';
import 'package:freego_flutter/http/http_tool.dart';

class VideoApi{

  VideoApi._internal();
  static final VideoApi _instance = VideoApi._internal();
  factory VideoApi(){
    return _instance;
  }

  Future<List<VideoModel>?> listByUser({required int userId, int limit = 10, int? maxId, int? minId, bool isDesc = true, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/video/list_by_user';
    List<VideoModel>? result = await HttpTool.get(url, {
      'userId': userId,
      'limit': limit,
      'maxId': maxId,
      'minId': minId,
      'isDesc': isDesc
    }, (response){
      List<VideoModel> list = [];
      for(dynamic item in response.data['data']){
        list.add(VideoModel.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return result;
  }

  Future<List<int>?> search({required String text, Function(Response)? fail, Function(Response)? success}) async{
    const String url = "/video/es_by_show_num";
    List<int>? result = await HttpTool.get(url, {
      'text': text
    }, (response){
      List<int> list = [];
      for(dynamic item in response.data['data']){
        list.add(item);
      }
      return list;
    }, fail: fail, success: success);
    return result;
  }

  Future<List<VideoModel>?> listByIds({required List<int> ids, Function(Response)? fail, Function(Response)? success}) async{
    const String url = "/video/ids";
    List<VideoModel>? result = await HttpTool.get(url, {
      'ids': ids
    }, (response){
      List<VideoModel> list = [];
      for(dynamic item in response.data['data']){
        list.add(VideoModel.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return result;
  }

  Future<bool> addShowNum({required int videoId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/video/add_show_num';
    bool? result = await HttpTool.put(url, {
      'videoId': videoId
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}
