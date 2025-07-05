
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/user_block/model/user_block_user.dart';
import 'package:freego_flutter/http/http_tool.dart';

class UserBlockUserApi{

  UserBlockUserApi._internal();
  static final UserBlockUserApi _instance = UserBlockUserApi._internal();
  factory UserBlockUserApi(){
    return _instance;
  }

  Future<List<UserBlockUser>?> list({String? keyword, int? pageNum = 1, int? pageSize = 20, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user_block_user/list';
    List<UserBlockUser>? list = await HttpTool.get(url, {
      'keyword': keyword,
      'pageNum': pageNum,
      'pageSize': pageSize
    }, (response){
      List<UserBlockUser> list = [];
      for(dynamic json in response.data['data']){
        list.add(UserBlockUser.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<List<UserBlockUser>?> range({String? keyword, int? minVal, int? maxVal, int? limit, bool isDesc = false, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user_block_user/range';
    List<UserBlockUser>? list = await HttpTool.get(url, {
      'keyword': keyword,
      'minVal': minVal,
      'maxVal': maxVal,
      'limit': limit,
      'isDesc': isDesc
    }, (response){
      List<UserBlockUser> list = [];
      for(dynamic json in response.data['data']){
        list.add(UserBlockUser.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<bool> block({required int blockId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user_block_user';
    bool? result = await HttpTool.post(url, {
      'blockId': blockId
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }

  Future<bool> unblock({required int blockId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user_block_user';
    bool? result = await HttpTool.delete(url, {
      'blockId': blockId
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}
