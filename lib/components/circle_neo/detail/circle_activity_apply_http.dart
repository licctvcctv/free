
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

class CircleActivityApplyHttp{

  CircleActivityApplyHttp._internal();
  static final CircleActivityApplyHttp _instance = CircleActivityApplyHttp._internal();
  factory CircleActivityApplyHttp(){
    return _instance;
  }

  Future<bool> apply({required int circleId, String? remark, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/circle/activity/apply';
    bool? result = await HttpTool.post(url, {
      'circleId': circleId,
      'remark': remark
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }

  Future<bool> setStatus({required int applyId, required CircleActivityApplyStatus status, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/circle/activity/apply';
    bool? result = await HttpTool.put(url, {
      'applyId': applyId,
      'status': status.getNum(),
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}
