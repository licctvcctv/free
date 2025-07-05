
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

class HttpUserLike {

  static Future<bool> like(int targetId, ProductType type, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user/like';
    bool? result = await HttpTool.post(url, {
      'targetId': targetId,
      'type': type.getNum()
    }, (response){
      return true;
    });
    return result ?? false;
  }

  static Future<bool> unlike(int targetId, ProductType type, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user/like';
    bool? result = await HttpTool.delete(url, {
      'targetId': targetId,
      'type': type.getNum()
    }, (response){
      return true;
    });
    return result?? false;
  }

}
