
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/local_storage/model/local_user.dart';

class LocalUserApi{

  LocalUserApi._internal();
  static final LocalUserApi _instance = LocalUserApi._internal();
  factory LocalUserApi(){
    return _instance;
  }

  Future<List<LocalUser>?> listSimpleUser({required List<int> ids, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user/simple_user/list';
    List<LocalUser>? list = await HttpTool.post(url, {
      'ids': ids
    }, (response){
      DateTime now = DateTime.now();
      List<LocalUser> list = [];
      for(dynamic json in response.data['data']){
        LocalUser localUser = LocalUser.fromJson(json);
        localUser.lastUpdateTime = now;
        list.add(localUser);
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<LocalUser?> getSimpleUser({required int id, Function(Response)? fail, Function(Response)? success}) async{
    String url = '/user/simple_user/$id';
    LocalUser? localUser = await HttpTool.get(url, {}, (response){
      LocalUser localUser = LocalUser.fromJson(response.data['data']);
      localUser.lastUpdateTime = DateTime.now();
      return localUser;
    }, fail: fail, success: success);
    return localUser;
  }
}
