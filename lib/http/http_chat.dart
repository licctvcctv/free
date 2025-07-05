
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_util.dart';
import 'package:freego_flutter/model/chat.dart';
import 'package:freego_flutter/util/storage.dart';
import 'package:freego_flutter/util/toast_util.dart';

class HttpChat{

  static Future<List<ChatRecord>?> recordAll({Function(Response)? fail, Function(Response)? success}) async{
    String url = '/chatrecord/all';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, data: {}, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取聊天状态记录失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<ChatRecord> list = toRecordList(response.data['data']['list']);
    return list;
  }

  static Future<List<ChatMessage>?> receiveMsg({Function(Response)? fail, Function(Response)? success}) async{
    String url = '/chatmessage/receive';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, data: {}, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取最新消息失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<ChatMessage> list = toMessageList(response.data['data']['list']);
    return list;
  }

  static Future<ChatRecord?> recordById(int fromId, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/chatrecord';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, data: {'fromId': fromId}, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取聊天状态记录失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    if(response.data['data'] == null){
      return null;
    }
    else{
      ChatRecord record = ChatRecord.fromJson(response.data['data']);
      return record;
    }
  }

  static Future<bool> statusSent(int lowId, int highId, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/chatmessage/sent';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.put(url, data: {
      'startId': lowId,
      'endId': highId
    }, token: token);
    if(response.statusCode != 200 || response.data['code'] != ResultCode.RES_OK){
      print('response: $response');
      if(fail == null){
        ToastUtil.error('已收回执失败');
      }
      else{
        fail(response);
      }
      return false;
    }
    if(success != null){
      success(response);
    }
    return true;
  }

  static Future<List<ChatMessage>?> history(int fromId, int endId, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/chatmessage/history';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.get(url, data: {
      'fromId': fromId,
      'endId': endId
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('获取历史消息失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    List<ChatMessage> list = toMessageList(response.data['data']['list']);
    return list;
  }

  static Future<bool> recordRead(int fromId, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/chatrecord/read';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.put(url, data: {
      'fromId': fromId
    }, token: token);
    if(response.statusCode != 200 || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('已读回执失败');
      }
      else{
        fail(response);
      }
      return false;
    }
    if(success != null){
      success(response);
    }
    return true;
  }

  static Future<bool> setNotDisturb(int fromId, bool val, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/chatrecord/notdisturb';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.put(url, data: {
      'fromId': fromId,
      'notDisturb': val
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('设置免打扰失败');
      }
      else{
        fail(response);
      }
      return false;
    }
    if(success != null){
      success(response);
    }
    return true;
  }

  static Future<bool> setRead(int fromId, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/chatrecord/read';
    String token = await Storage.readInfo<String>('user_token');
    Response response = await httpUtil.put(url, data: {
      'fromId': fromId
    }, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('设置已读失败');
      }
      else{
        fail(response);
      }
      return false;
    }
    if(success != null){
      success(response);
    }
    return true;
  }

  static List<ChatMessage> toMessageList(dynamic result){
    List<ChatMessage> list = [];
    for(Map<String, dynamic> item in result){
      list.add(ChatMessage.fromJson(item));
    }
    return list;
  }

  static List<ChatRecord> toRecordList(dynamic result){
    List<ChatRecord> list = [];
    for(Map<String, dynamic> item in result){
      list.add(ChatRecord.fromJson(item));
    }
    return list;
  }
}
