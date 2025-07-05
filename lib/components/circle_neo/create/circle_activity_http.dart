
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:intl/intl.dart';

class CircleActivityHttp{

  CircleActivityHttp._internal();
  static final CircleActivityHttp _instance = CircleActivityHttp._internal();
  factory CircleActivityHttp(){
    return _instance;
  }

  Future<bool> create({
    required String title,
    required String content,
    required int tripId,
    required double startLatitude,
    required double startLongitude,
    required String startAddress,
    required DateTime startTime,
    required int expectMin,
    required int expectMax,
    required List<String> picList,
    double? userLatitude,
    double? userLongitude,
    String? userCity,
    String? userAddress,
    Function(Response)? fail,
    Function(Response)? success
  }) async{
    const String url = '/circle/activity';
    bool? result = await HttpTool.post(url, {
      'title': title,
      'content': content,
      'tripId': tripId,
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'startAddress': startAddress,
      'startTime': DateFormat('yyyy-MM-dd').format(startTime),
      'expectMin': expectMin,
      'expectMax': expectMax,
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