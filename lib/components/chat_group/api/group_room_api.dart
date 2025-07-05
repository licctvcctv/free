
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/chat_group/pojo/im_group_room.dart';
import 'package:freego_flutter/http/http_tool.dart';

class GroupRoomApi{

  GroupRoomApi._internal();
  static final GroupRoomApi _instance = GroupRoomApi._internal();
  factory GroupRoomApi(){
    return _instance;
  }

  Future<List<ImGroupRoom>?> listUnsent({Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im_group_room/unsent';
    List<ImGroupRoom>? list = await HttpTool.get(url, {}, (response){
      List<ImGroupRoom> list = [];
      for(dynamic json in response.data['data']){
        list.add(ImGroupRoom.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<ImGroupRoom?> enter({required int groupId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im_group_room/enter';
    ImGroupRoom? room = await HttpTool.get(url, {
      'groupId': groupId
    }, (response){
      return ImGroupRoom.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return room;
  }

  Future<bool> update({required int id, String? groupRemark, String? memberRemark, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im_group_room';
    bool? result = await HttpTool.put(url, {
      'id': id,
      'groupRemark': groupRemark,
      'memberRemark': memberRemark
    }, (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }
}
