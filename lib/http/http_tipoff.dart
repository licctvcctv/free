
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';

enum TipoffType{
  user,
  content
}

extension TipoffTypeExt on TipoffType{
  int getNum(){
    switch(this){
      case TipoffType.user:
        return 0;
      case TipoffType.content:
        return 1;
    }
  }
  static TipoffType? getType(int num){
    for(TipoffType type in TipoffType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

class HttpTipoff{

  static Future<bool> postTipoff(
    {
      required String reason, 
      required String descrip, 
      List<String> picList = const [],
      int type = 1,
      int? targetType, 
      required int targetId, 
      Function(Response)? success, 
      Function(Response)? fail
    }) async{
    const String url = '/tipoff';
    bool? result = await HttpTool.post(url, {
      'reason': reason,
      'descrip': descrip,
      'pics': picList.join(','),
      'type': type,
      'targetType': targetType,
      'targetId': targetId
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}
