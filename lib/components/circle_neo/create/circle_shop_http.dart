
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';

class CircleShopHttp{

  CircleShopHttp._internal();
  static final CircleShopHttp _instance = CircleShopHttp._internal();
  factory CircleShopHttp(){
    return _instance;
  }

  Future<bool> create({
    required String title,
    required String content,
    required List<String> picList,
    String? openTime,
    String? closeTime,
    String? openDays,
    String? phone,
    double? userLatitude,
    double? userLongitude,
    String? userCity,
    String? userAddress,
    Function(Response)? fail,
    Function(Response)? success
  }) async{
    const String url = '/circle/shop';
    bool? result = await HttpTool.post(url, {
      'title': title,
      'content': content,
      'picList': picList,
      'openTime': openTime,
      'closeTime': closeTime,
      'openDays': openDays,
      'phone': phone,
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
