
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';

class CircleArticleHttp{

  CircleArticleHttp._internal();
  static final CircleArticleHttp _instance = CircleArticleHttp._internal();
  factory CircleArticleHttp(){
    return _instance;
  }

  Future<bool> create({
    required String title,
    required String content,
    required List<String> picList,
    double? userLatitude,
    double? userLongitude,
    String? userCity,
    String? userAddress,
    Function(Response)? fail,
    Function(Response)? success
  }) async{
    const String url = '/circle/article';
    bool? result = await HttpTool.post(url, {
      'title': title,
      'content': content,
      'picList': picList,
      'userCity': userCity,
      'userAddress': userAddress,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}
