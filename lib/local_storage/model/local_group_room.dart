
import 'package:freego_flutter/components/chat_group/pojo/im_group_room.dart';

class LocalGroupRoom{

  int? id;
  int? groupId;
  String? groupRemark;
  int? memberRank;
  int? memberId;
  String? memberRemark;
  String? memberRole;
  DateTime? joinTime;
  DateTime? leaveTime;
  bool? isLeft;
  int? lastMessageId;
  String? lastMessageSenderType;
  String? lastMessageContent;
  String? lastMessageType;
  DateTime? lastMessageTime;
  int? unreadNum;
  bool? notDisturb;
  DateTime? lastUpdateTime;

  LocalGroupRoom();
  LocalGroupRoom.fromSqlMap(Map<String, dynamic> map){
    id = map['id'];
    groupId = map['group_id'];
    groupRemark = map['group_remark'];
    memberRank = map['member_rank'];
    memberId = map['member_id'];
    memberRemark = map['member_remark'];
    memberRole = map['member_role'];
    if(map['join_time'] is int){
      joinTime = DateTime.fromMillisecondsSinceEpoch(map['join_time']);
    }
    if(map['leave_time'] is int){
      leaveTime = DateTime.fromMillisecondsSinceEpoch(map['leave_time']);
    }
    isLeft = (map['is_left'] ?? 0) > 0;
    lastMessageId = map['last_message_id'];
    lastMessageSenderType = map['last_message_sender_type'];
    lastMessageContent = map['last_message_content'];
    lastMessageType = map['last_message_type'];
    if(map['last_message_time'] is int){
      lastMessageTime = DateTime.fromMillisecondsSinceEpoch(map['last_message_time']);
    }
    unreadNum = map['unread_num'];
    notDisturb = (map['not_disturb'] ?? 0) > 0;
    if(map['last_update_time'] is int){
      lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(map['last_update_time']);
    }
  }
  Map<String, Object?> toSqlMap(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['group_id'] = groupId;
    map['group_remark'] = groupRemark;
    map['member_rank'] = memberRank;
    map['member_id'] = memberId;
    map['member_remark'] = memberRemark;
    map['member_role'] = memberRole;
    map['join_time'] = joinTime?.millisecondsSinceEpoch;
    map['leave_time'] = leaveTime?.millisecondsSinceEpoch;
    map['is_left'] = isLeft == true ? 1 : 0;
    map['unread_num'] = unreadNum;
    map['not_disturb'] = notDisturb == true ? 1 : 0;
    map['last_update_time'] = lastUpdateTime?.millisecondsSinceEpoch;
    return map;
  }

  LocalGroupRoom.fromImGroupRoom(ImGroupRoom room){
    id = room.id;
    groupId = room.groupId;
    groupRemark = room.groupRemark;
    memberRank = room.memberRank;
    memberId = room.memberId;
    memberRemark = room.memberRemark;
    memberRole = room.memberRole;
    joinTime = room.joinTime;
    leaveTime = room.leaveTime;
    unreadNum = room.unreadNum;
    notDisturb = room.notDisturb;
    lastUpdateTime = DateTime.now();
  }
}

class LocalGroupRoomVo{

  int? id;
  int? groupId;

  String? groupName;
  String? groupRemark;
  
  int? memberRank;
  int? memberId;
  String? memberRemark;
  String? memberRole;
  DateTime? joinTime;
  DateTime? leaveTime;
  bool? isLeft;
  int? unreadNum;
  bool? notDisturb;
  DateTime? lastUpdateTime;

  int? lastMessageId;
  String? lastMessageSenderType;
  String? lastMessageContent;
  String? lastMessageType;
  DateTime? lastMessageTime;
  String? lastMessageSenderName;

  LocalGroupRoomVo();
  LocalGroupRoomVo.fromSqlMap(Map<String, dynamic> map){
    id = map['id'];
    groupId = map['group_id'];
    groupName = map['group_name'];
    groupRemark = map['group_remark'];
    memberRank = map['member_rank'];
    memberId = map['member_id'];
    memberRemark = map['member_remark'];
    memberRole = map['member_role'];
    if(map['join_time'] is int){
      joinTime = DateTime.fromMillisecondsSinceEpoch(map['join_time']);
    }
    if(map['leave_time'] is int){
      leaveTime = DateTime.fromMillisecondsSinceEpoch(map['leave_time']);
    }
    isLeft = (map['is_left'] ?? 0) > 0;
    unreadNum = map['unread_num'];
    notDisturb = (map['not_disturb'] ?? 0) > 0;
    if(map['last_update_time'] is int){
      lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(map['last_update_time']);
    }

    lastMessageId = map['last_message_id'];
    lastMessageSenderType = map['last_message_sender_type'];
    lastMessageContent = map['last_message_content'];
    lastMessageType = map['last_message_type'];
    if(map['last_message_time'] is int){
      lastMessageTime = DateTime.fromMillisecondsSinceEpoch(map['last_message_time']);
    }
    lastMessageSenderName = map['last_message_sender_name'];
  }
}
