
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/util/tuple.dart';

class ChatHttpSingle{

  static Future<List<ImSingleMessage>?> getHistory(int roomId, {int? maxId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im/single/message/history';
    List<ImSingleMessage>? list = await HttpTool.get(url, {
      'roomId': roomId,
      'maxId': maxId,
    }, (response){
      List<ImSingleMessage> list = [];
      for(dynamic json in response.data['data']){
        list.add(ImSingleMessage.fromJson(json));
      }
      return list;
    });
    return list;
  }

  static Future<Tuple<List<ImSingleRoom>, List<ImSingleMessage>>?> getAllUnsent({Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im/single/unsent';
    Tuple<List<ImSingleRoom>, List<ImSingleMessage>>? tuple = await HttpTool.get(url, {}, (response){
      if(response.data['data'] == null){
        return null;
      }
      List<ImSingleRoom> roomList = [];
      for(dynamic json in response.data['data']['room'] ?? []){
        roomList.add(ImSingleRoom.fromJson(json));
      }
      List<ImSingleMessage> messageList = [];
      for(dynamic json in response.data['data']['message'] ?? []){
        messageList.add(ImSingleMessage.fromJson(json));
      }
      return Tuple(roomList, messageList);
    }, fail: fail, success: success);
    return tuple;
  }

  static Future<List<ImSingleMessage>?> getUnsentMessage({Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im/single/message/unsent';
    List<ImSingleMessage>? list = await HttpTool.get(url, {}, (response){
      List<ImSingleMessage> list = [];
      for(dynamic json in response.data['data']){
        list.add(ImSingleMessage.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  static Future<List<ImSingleRoom>?> getRoomWithUnsent({Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im/single/room/all';
    List<ImSingleRoom>? list = await HttpTool.get(url, {}, (response){
      List<ImSingleRoom> list = [];
      for(dynamic json in response.data['data']){
        list.add(ImSingleRoom.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  static Future<ImSingleRoom?> enterRoom(int partnerId, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im/single/room/enter';
    ImSingleRoom? room = await HttpTool.get(url, {
      'partnerId': partnerId
    }, (response){
      return ImSingleRoom.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return room;
  }

  static Future<ImSingleRoom?> getRoom(int roomId, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/im/single/room';
    ImSingleRoom? room = await HttpTool.get(url, {
      'roomId': roomId
    }, (response){
      return ImSingleRoom.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return room;
  }
}
