
import 'dart:async';
import 'dart:io';
import 'dart:convert' show json;

import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_storage.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:intl/intl.dart';

class _MyAfterLoginHandler implements AfterLoginHandler{
  @override
  void handle(UserModel user) {
    ChatSocket.close();
    ChatSocket.init();
  }
  
}

class _MyAfterLogoutHandler implements AfterLogoutHandler{
  @override
  void handle(UserModel user) {
    ChatSocket.close();
  }
  
}

class ChatSocket{

  static final _MyAfterLoginHandler _afterLoginHandler = _MyAfterLoginHandler();
  static final _MyAfterLogoutHandler _afterLogoutHandler = _MyAfterLogoutHandler();

  static const int heartBeatSeconds = 10;
  static const String MESSAGE_SYSTEM = 'system';
  static const String MESSAGE_SINGLE = 'single';
  static const String MESSAGE_GROUP = 'group';
  static const String MESSAGE_NOTIFICATION = 'notification';

  static WebSocket? _webSocket;
  static Timer? _heartbeatTimer;
  static List<ChatMessageHandler> _messageHandlerList = [];

  static int? _lastHeartbeatMillis;
  static Timer? _heartbeatEchoTimer;
  static final HeartbeatEchoHandler _heartbeatEchoHandler = HeartbeatEchoHandler();
  static List<SocketReconnectHandler> _reconnectHandlerList = [];

  static int get nextMidVal{
    return ChatStorageSingle.nextMid;
  }

  static void close(){
    _webSocket?.close();
    _heartbeatTimer?.cancel();
    _heartbeatEchoTimer?.cancel();
    _webSocket = null;
  }

  static bool addReconnectHandler(SocketReconnectHandler handler){
    if(_reconnectHandlerList.contains(handler)){
      return false;
    }
    List<SocketReconnectHandler> tmpList = [];
    tmpList.addAll(_reconnectHandlerList);
    tmpList.add(handler);
    tmpList.sort((a, b) => a.priority.compareTo(b.priority));
    _reconnectHandlerList = tmpList;
    return true;
  }

  static bool removeReconnectHandler(SocketReconnectHandler handler){
    return _reconnectHandlerList.remove(handler);
  }

  static bool addMessageHandler(ChatMessageHandler handler){
    if(_messageHandlerList.contains(handler)){
      return false;
    }
    List<ChatMessageHandler> tmpList = [];
    tmpList.addAll(_messageHandlerList);
    tmpList.add(handler);
    tmpList.sort((a, b){
      return a.priority.compareTo(b.priority);
    });
    _messageHandlerList = tmpList;
    return true;
  }

  static bool removeMessageHandler(ChatMessageHandler handler){
    return _messageHandlerList.remove(handler);
  }

  static Future init() async{
    LocalUser.addAfterLoginHandler(_afterLoginHandler);
    LocalUser.addAfterLogoutHandler(_afterLogoutHandler);
    if(_webSocket != null){
      return;
    }
    String? token = await LocalUser.getSavedToken();
    if(token == null){
      return;
    }
    _webSocket = await WebSocket.connect("${URL_BASE_HOST.replaceFirst("http", "ws")}/websocket/$token");
    addMessageHandler(_heartbeatEchoHandler);
    _webSocket!.listen((content) async{
      Map<String, Object?> rawMap = json.decoder.convert(content);
      MessageObject rawObj = MessageObject.fromJson(rawMap);
      for(ChatMessageHandler handler in _messageHandlerList){
        await handler.handle(rawObj);
      }
    }, onError: (Object error){
      close();
      init();
    });
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: heartBeatSeconds), (timer) {
      SystemMessage message = SystemMessage();
      message.type = MessageType.heartbeat.getNum();
      message.sendTime = DateTime.now();
      MessageObject rawObj = MessageObject();
      rawObj.name = MESSAGE_SYSTEM;
      rawObj.body = json.encoder.convert(message.toJson());
      _webSocket?.add(json.encoder.convert(rawObj.toJson()));
    });
    _heartbeatEchoTimer?.cancel();
    _heartbeatEchoTimer = Timer.periodic(const Duration(seconds: heartBeatSeconds * 2), (timer) {
      bool flag = false;
      if(_lastHeartbeatMillis == null){
        flag = true;
      }
      if(!flag){
        int currentMillis = DateTime.now().millisecondsSinceEpoch;
        if(currentMillis - _lastHeartbeatMillis! > heartBeatSeconds * 2 * 1000){
          flag = true;
        }
      }
      if(flag){
        print('socket reconnect!');
        close();
        init().then((value) async{
          for(SocketReconnectHandler handler in _reconnectHandlerList){
            await handler.handle();
          }
        });
      }
    });
  }

  static Future sendMessage(MessageObject rawMessage) async{
    await init();
    _webSocket?.add(json.encoder.convert(rawMessage));
  }
}

abstract class SocketReconnectHandler{
  late int priority;
  SocketReconnectHandler({this.priority = 0});
  Future handle();
}

abstract class ChatMessageHandler{
  late int priority;
  ChatMessageHandler({this.priority = 0});
  Future handle(MessageObject rawObj);
}

class HeartbeatEchoHandler extends ChatMessageHandler{

  HeartbeatEchoHandler() : super(priority: 0);

  @override
  Future handle(MessageObject rawObj) async{
    if(rawObj.name != ChatSocket.MESSAGE_SYSTEM){
      return;
    }
    if(rawObj.body is! String){
      return;
    }
    dynamic bodyObj = json.decoder.convert(rawObj.body!);
    SystemMessage message = SystemMessage.fromJson(bodyObj);
    if(message.type == MessageType.heartbeat.getNum()){
      ChatSocket._lastHeartbeatMillis = DateTime.now().millisecondsSinceEpoch;
    }
  }
  
}

class MessageObject{
  String? name;
  String? body;

  MessageObject();
  MessageObject.fromJson(dynamic json){
    name = json['name'];
    body = json['body'];
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['name'] = name;
    map['body'] = body;
    return map;
  }
}

class SystemMessage{
  int? senderRoomId;
  int? senderRoomType;
  int? type;
  String? content;
  DateTime? sendTime;

  SystemMessage();

  SystemMessage.fromJson(dynamic json){
    senderRoomId = json['senderRoomId'];
    senderRoomType = json['senderRoomType'];
    type = json['type'];
    content = json['content'];
    if(json['sendTime'] is String){
      sendTime = DateTime.tryParse(json['sendTime']);
    }
  }

  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['senderRoomId'] = senderRoomId;
    map['senderRoomType'] = senderRoomType;
    map['type'] = type;
    map['content'] = content;
    map['sendTime'] = sendTime == null ? null : DateFormat('yyyy-MM-dd HH:mm:ss').format(sendTime!);
    return map;
  }
}
