
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';

class VideoToolApi{

  VideoToolApi._internal();
  static final VideoToolApi _instance = VideoToolApi._internal();
  factory VideoToolApi(){
    return _instance;
  }

  Future<String?> getInfo({required String url, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/video_tool/graph/guess';
    String? result = await HttpTool.post(url, {
      'url': url
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return result;
  }

  Future<String?> getFrameInfo({required int id, required int millis, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/video_tool/video/frame/guess';
    String? result = await HttpTool.post(url, {
      'id': id,
      'millis': millis
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return result;
  }
}
