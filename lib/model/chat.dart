
import 'package:intl/intl.dart';
import 'dart:convert' show json;

class ChatMessage{
  int? id;
  int? mid;
  int? fromId;
  int? toId;
  int? chatType;
  int? msgType;
  String? msgContent;
  String? msgUrl;
  double? msgLat;
  double? msgLng;
  Object? ext;
  DateTime? sendTime;
  int? status;
  int? readStatus;
  String? localPath;
  ChatMessage();
  ChatMessage.fromJson(dynamic map){
    id = map['id'];
    mid = map['mid'];
    fromId = map['fromId'];
    toId = map['toId'];
    chatType = map['chatType'];
    msgType = map['msgType'];
    msgContent = map['msgContent'];
    msgUrl = map['msgUrl'];
    msgLat = map['msgLat'];
    msgLng = map['msgLng'];
    ext = map['ext'];
    sendTime = map['sendTime'] != null ? DateTime.parse(map['sendTime']) : null;
    status = map['status'];
    readStatus = map['readStatus'];
    localPath = map['localPath'];
  }
  ChatMessage.fromSqfliteJson(dynamic map){
    id = map['id'];
    mid = map['mid'];
    fromId = map['from_id'];
    toId = map['to_id'];
    chatType = map['chat_type'];
    msgType = map['msg_type'];
    msgContent = map['msg_content'];
    msgUrl = map['msg_url'];
    msgLat = map['msg_lat'];
    msgLng = map['msg_lng'];
    if(map['ext'] != null){
      ext = json.decoder.convert(map['ext']);
    }
    sendTime = map['send_time'] != null ? DateTime.fromMillisecondsSinceEpoch(map['send_time']) : null;
    status = map['status'];
    readStatus = map['read_status'];
    localPath = map['local_path'];
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = <String, Object?>{};
    map['id'] = id;
    map['mid'] = mid;
    map['fromId'] = fromId;
    map['toId'] = toId;
    map['chatType'] = chatType;
    map['msgType'] = msgType;
    map['msgContent'] = msgContent;
    map['msgUrl'] = msgUrl;
    map['msgLat'] = msgLat;
    map['msgLng'] = msgLng;
    map['ext'] = ext;
    map['sendTime'] = sendTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(sendTime!) : null;
    map['status'] = status;
    map['readStatus'] = readStatus;
    // map['localPath'] = localPath;
    return map;
  }
  Map<String, Object?> toSqfliteJson(){
    Map<String, Object?> map = <String, Object?>{};
    map['id'] = id;
    map['mid'] = mid;
    map['from_id'] = fromId;
    map['to_id'] = toId;
    map['chat_type'] = chatType;
    map['msg_type'] = msgType;
    map['msg_content'] = msgContent;
    map['msg_url'] = msgUrl;
    map['msg_lat'] = msgLat;
    map['msg_lng'] = msgLng;
    if(ext != null){
      map['ext'] = json.encoder.convert(ext);
    }
    map['send_time'] = sendTime?.millisecondsSinceEpoch;
    map['status'] = status;
    map['read_status'] = readStatus;
    map['local_path'] = localPath;
    return map;
  }

  static const STATUS_PREPARED = -1;
  static const STATUS_SENDING = 0;
  static const STATUS_SENT = 1;
  static const STATUS_RETRACTED = 2;
  static const READ_STATUS_UNREAD = 0;
  static const READ_STATUS_READ = 1;
}

class ChatRecord{
  int? id;
  int? fromId;
  int? toId;
  int? lastMsgId;
  int? unreadNum;
  bool? notDisturb;
  int? status;
  int? lastMsgUid;
  int? chatType;
  int? lastMsgType;
  String? lastMsgContent;
  DateTime? lastMsgTime;
  Object? ext;
  int? readStatus;
  String? userName;
  String? userHead;
  ChatRecord.fromJson(dynamic map){
    id = map['id'];
    fromId = map['fromId'];
    toId = map['toId'];
    lastMsgId = map['lastMsgId'];
    unreadNum = map['unreadNum'];
    notDisturb = map['notDisturb'] != null && map['notDisturb'] > 0;
    status = map['status'];
    lastMsgUid = map['lastMsgUid'];
    chatType = map['chatType'];
    lastMsgType = map['lastMsgType'];
    lastMsgContent = map['lastMsgContent'];
    lastMsgTime = map['lastMsgType'] != null ? DateTime.parse(map['lastMsgTime']) : null;
    ext = map['ext'];
    readStatus = map['readStatus'];
    userName = map['userName'];
    userHead = map['userHead'];
  }
  ChatRecord.fromSqfliteJson(dynamic map){
    id = map['id'];
    fromId = map['from_id'];
    toId = map['to_id'];
    lastMsgId = map['last_msg_id'];
    unreadNum = map['unread_num'];
    notDisturb = map['not_disturb'] != null && map['not_disturb'] > 0;
    status = map['status'];
    lastMsgUid = map['last_msg_uid'];
    chatType = map['chat_type'];
    lastMsgType = map['last_msg_type'];
    lastMsgContent = map['last_msg_content'];
    lastMsgTime = map['last_msg_time'] != null ? DateTime.fromMillisecondsSinceEpoch(map['last_msg_time']) : null;
    if(map['ext'] != null){
      ext = json.decoder.convert(map['ext']);
    }
    readStatus = map['read_status'];
    userName = map['user_name'];
    userHead = map['user_head'];
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = <String, Object?>{};
    map['id'] = id;
    map['fromId'] = fromId;
    map['toId'] = toId;
    map['lastMsgId'] = lastMsgId;
    map['unreadNum'] = unreadNum;
    map['notDisturb'] = notDisturb;
    map['status'] = status;
    map['lastMsgUid'] = lastMsgUid;
    map['chatType'] = chatType;
    map['lastMsgType'] = lastMsgType;
    map['lastMsgContent'] = lastMsgContent;
    map['lastMsgTime'] = lastMsgTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(lastMsgTime!) : null;
    map['ext'] = ext;
    map['readStatus'] = readStatus;
    map['userName'] = userName;
    map['userHead'] = userHead;
    return map;
  }
  Map<String, Object?> toSqfliteJson(){
    Map<String, Object?> map = <String, Object?>{};
    map['id'] = id;
    map['from_id'] = fromId;
    map['to_id'] = toId;
    map['last_msg_id'] = lastMsgId;
    map['unread_num'] = unreadNum;
    map['not_disturb'] = notDisturb;
    map['status'] = status;
    map['last_msg_uid'] = lastMsgUid;
    map['chat_type'] = chatType;
    map['last_msg_type'] = lastMsgType;
    map['last_msg_content'] = lastMsgContent;
    map['last_msg_time'] =  lastMsgTime?.millisecondsSinceEpoch;
    if(ext != null){
      map['ext'] = json.encoder.convert(ext);
    }
    map['read_status'] = readStatus;
    map['user_name'] = userName;
    map['user_head'] = userHead;
    return map;
  }
}
