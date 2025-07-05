
import 'dart:convert' show json;

import 'package:intl/intl.dart';

class MessageCommand<T>{
  int? cmdType;
  T? cmdValue;
  MessageCommand(this.cmdType, this.cmdValue);
  MessageCommand.fromText(String text){
    Map<String, Object?> rawObj = json.decoder.convert(text);
    if(rawObj['cmdType'] is int){
      cmdType = rawObj['cmdType'] as int;
    }
    if(rawObj['cmdValue'] is T){
      cmdValue = rawObj['cmdValue'] as T;
    } 
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    if(cmdType != null){
      map['cmdType'] = cmdType;
    }
    if(cmdValue != null){
      map['cmdValue'] = cmdValue;
    }
    return map;
  }
}

class ImSingleMessage{
  late int id;
  int? localId;
  int? sendRoomId;
  int? receiveRoomId;
  int? senderType;
  int? viewerType;
  String? content;
  int? type;
  String? url;
  int? quoteMsgId;
  int? quoteType;
  String? quoteContent;
  String? quoteUrl;
  DateTime? sendTime;
  int? sendStatus;
  String? localPath;

  ImSingleMessage(this.id);

  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['localId'] = localId;
    map['sendRoomId'] = sendRoomId;
    map['receiveRoomId'] = receiveRoomId;
    map['senderType'] = senderType;
    map['viewerType'] = viewerType;
    map['content'] = content;
    map['type'] = type;
    map['url'] = url;
    map['quoteMsgId'] = quoteMsgId;
    map['quoteType'] = quoteType;
    map['quoteContent'] = quoteContent;
    map['quoteUrl'] = quoteUrl;
    map['sendTime'] = sendTime == null ? null : DateFormat('yyyy-MM-dd HH:mm:ss').format(sendTime!);
    map['sendStatus'] = sendStatus;
    return map;
  }
  Map<String, Object?> toSqlMap(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['local_id'] = localId;
    map['send_room_id'] = sendRoomId;
    map['receive_room_id'] = receiveRoomId;
    map['sender_type'] = senderType;
    map['viewer_type'] = viewerType;
    map['content'] = content;
    map['type'] = type;
    map['url'] = url;
    map['quote_msg_id'] = quoteMsgId;
    map['quote_type'] = quoteType;
    map['quote_content'] = quoteContent;
    map['quote_url'] = quoteUrl;
    map['send_time'] = sendTime == null ? null : sendTime!.millisecondsSinceEpoch;
    map['send_status'] = sendStatus;
    map['local_path'] = localPath;
    return map;
  }

  ImSingleMessage.fromJson(dynamic json){
    id = json['id'];
    localId = json['localId'];
    sendRoomId = json['sendRoomId'];
    receiveRoomId = json['receiveRoomId'];
    senderType = json['senderType'];
    viewerType = json['viewerType'];
    content = json['content'];
    type = json['type'];
    url = json['url'];
    quoteMsgId = json['quoteMsgId'];
    quoteType = json['quoteType'];
    quoteContent = json['quoteContent'];
    quoteUrl = json['quoteUrl'];
    if(json['sendTime'] != null){
      sendTime = DateTime.tryParse(json['sendTime']);
    }
    sendStatus = json['sendStatus'];
  }
  ImSingleMessage.fromSqlMap(dynamic json){
    id = json['id'];
    localId = json['local_id'];
    sendRoomId = json['send_room_id'];
    receiveRoomId = json['receive_room_id'];
    senderType = json['sender_type'];
    viewerType = json['viewer_type'];
    content = json['content'];
    type = json['type'];
    url = json['url'];
    quoteMsgId = json['quote_msg_id'];
    quoteType = json['quote_type'];
    quoteContent = json['quote_content'];
    quoteUrl = json['quote_url'];
    if(json['send_time'] != null && json['send_time'] is int){
      sendTime = DateTime.fromMillisecondsSinceEpoch(json['send_time']);
    }
    sendStatus = json['send_status'];
    localPath = json['local_path'];
  }
}

class ImSingleRoom{
  late int id;
  int? ownnerId;
  int? partnerId;
  String? partnerName;
  String? partnerHead;
  String? partnerRemark;
  int? lastMessageSender;
  int? lastMessageId;
  int? lastMessageType;
  String? lastMessageBrief;
  DateTime? lastMessageTime;
  int? unreadNum;
  bool? notDisturb;
  int? lastReadId;
  int? lastSentId;
  DateTime? createTime;
  bool? isActivated;

  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['ownnerId'] = ownnerId;
    map['partnerId'] = partnerId;
    map['partnerName'] = partnerName;
    map['partnerHead'] = partnerHead;
    map['partnerRemark'] = partnerRemark;
    map['lastMessageSender'] = lastMessageSender;
    map['lastMessageId'] = lastMessageId;
    map['lastMessageType'] = lastMessageType;
    map['lastMessageBrief'] = lastMessageBrief;
    map['lastMessageTime'] = lastMessageTime == null ? null : DateFormat('yyyy-MM-dd HH:mm:ss').format(lastMessageTime!);
    map['unreadNum'] = unreadNum;
    map['notDisturb'] = notDisturb;
    map['lastReadId'] = lastReadId;
    map['lastSentId'] = lastSentId;
    map['createTime'] = createTime == null ? null : DateFormat('yyyy-MM-dd HH:mm:ss').format(createTime!);
    map['isActivated'] = isActivated;
    return map;
  }
  Map<String, Object?> toSqlMap(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['ownner_id'] = ownnerId;
    map['partner_id'] = partnerId;
    map['partner_name'] = partnerName;
    map['partner_head'] = partnerHead;
    map['partner_remark'] = partnerRemark;
    map['last_message_sender'] = lastMessageSender;
    map['last_message_id'] = lastMessageId;
    map['last_message_type'] = lastMessageType;
    map['last_message_brief'] = lastMessageBrief;
    map['last_message_time'] = lastMessageTime == null ? null : lastMessageTime!.millisecondsSinceEpoch;
    map['unread_num'] = unreadNum;
    map['not_disturb'] = notDisturb == true ? 1 : 0;
    map['last_read_id'] = lastReadId;
    map['last_sent_id'] = lastSentId;
    map['create_time'] = createTime == null ? null : createTime!.millisecondsSinceEpoch;
    map['is_activated'] = isActivated == true ? 1 : 0;
    return map;
  }

  ImSingleRoom.fromJson(dynamic json){
    id = json['id'];
    ownnerId = json['ownnerId'];
    partnerId = json['partnerId'];
    partnerName = json['partnerName'];
    partnerHead = json['partnerHead'];
    partnerRemark = json['partnerRemark'];
    lastMessageSender = json['lastMessageSender'];
    lastMessageId = json['lastMessageId'];
    lastMessageType = json['lastMessageType'];
    lastMessageBrief = json['lastMessageBrief'];
    if(json['lastMessageTime'] != null){
      lastMessageTime = DateTime.tryParse(json['lastMessageTime']);
    }
    unreadNum = json['unreadNum'];
    notDisturb = json['notDisturb'];
    lastReadId = json['lastReadId'];
    lastSentId = json['lastSentId'];
    if(json['createTime'] != null){
      createTime = DateTime.tryParse(json['createTime']);
    }
    isActivated = json['isActivated'];
  }
  ImSingleRoom.fromSqlMap(dynamic json){
    id = json['id'];
    ownnerId = json['ownner_id'];
    partnerId = json['partner_id'];
    partnerName = json['partner_name'];
    partnerHead = json['partner_head'];
    partnerRemark = json['partner_remark'];
    lastMessageSender = json['last_message_sender'];
    lastMessageId = json['last_message_id'];
    lastMessageType = json['last_message_type'];
    lastMessageBrief = json['last_message_brief'];
    if(json['last_message_time'] != null && json['last_message_time'] is int){
      lastMessageTime = DateTime.fromMillisecondsSinceEpoch(json['last_message_time']);
    }
    unreadNum = json['unread_num'];
    notDisturb = json['not_disturb'] > 0;
    lastReadId = json['last_read_id'];
    lastSentId = json['last_sent_id'];
    if(json['create_time'] != null && json['create_time'] is int){
      createTime = DateTime.fromMillisecondsSinceEpoch(json['create_time']);
    }
    isActivated = json['is_activated'] > 0;
  }
}

enum SenderType{
  system,
  ownner,
  partner
}

extension SenderTypeExt on SenderType{
  int getNum(){
    switch(this){
      case SenderType.system:
        return 0;
      case SenderType.ownner:
        return 1;
      case SenderType.partner:
        return 2;
    }
  }
  static SenderType? getType(int num){
    for(SenderType type in SenderType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

enum SendStatus{
  fail,
  unsent,
  sending,
  sent,
  retracted,
  deleted
}

extension SendStatusExt on SendStatus{
  int getNum(){
    switch(this){
      case SendStatus.deleted:
        return -3;
      case SendStatus.fail:
        return -2;
      case SendStatus.unsent:
        return -1;
      case SendStatus.sending:
        return 0;
      case SendStatus.sent:
        return 1;
      case SendStatus.retracted:
        return 2;
    }
  }
  static SendStatus? getStatus(int num){
    for(SendStatus status in SendStatus.values){
      if(status.getNum() == num){
        return status;
      }
    }
    return null;
  }
}

enum MessageType{
  heartbeat,
  text,
  image,
  file,
  location,
  audio,
  video,
  command,
  notifyCommand,
  // command与notifyCommand的区别：
  // command是一次性命令，执行完成后不会在本地保存，也不会显示在消息界面上
  // notifyCommand会在本地保存，且会在消息界面上显示提示信息
  freegoVideo
}

extension MessageTypeExt on MessageType{
  int getNum(){
    switch(this){
      case MessageType.heartbeat:
        return 0;
      case MessageType.text:
        return 1;
      case MessageType.image:
        return 2;
      case MessageType.file:
        return 3;
      case MessageType.location:
        return 4;
      case MessageType.audio:
        return 5;
      case MessageType.video:
        return 6;
      case MessageType.command:
        return 7;
      case MessageType.notifyCommand:
        return 8;
      case MessageType.freegoVideo:
        return 21;
    }
  }
  static MessageType? getType(int num){
    for(MessageType type in MessageType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

enum CommandType{
  sending,
  sent,
  read,
  retracting,
  retracted,
  retractFail,
  newPartner,
  groupCreated,
  groupNewAnnouncement,
  groupNewMember,
  groupMemberRemoved,
  groupMemberQuit,
  groupDismissed
}

extension CommandTypeExt on CommandType{
  int getNum(){
    switch(this){
      case CommandType.sending:
        return 1;
      case CommandType.sent:
        return 2;
      case CommandType.read:
        return 3;
      case CommandType.retracting:
        return 4;
      case CommandType.retracted:
        return 5;
      case CommandType.retractFail:
        return 6;
      case CommandType.newPartner:
        return 7;
      case CommandType.groupCreated:
        return 21;
      case CommandType.groupNewAnnouncement:
        return 22;
      case CommandType.groupNewMember:
        return 23;
      case CommandType.groupMemberRemoved:
        return 24;
      case CommandType.groupMemberQuit:
        return 25;
      case CommandType.groupDismissed:
        return 26;
    }
  }
  static CommandType? getType(int num){
    for(CommandType type in CommandType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}
