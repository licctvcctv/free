
import 'package:freego_flutter/components/chat_group/pojo/im_group_member.dart';

class LocalGroupMember{

  int? id;
  int? groupId;
  int? memberRank;
  int? memberId;
  String? memberRemark;
  String? memberRole;
  DateTime? joinTime;
  DateTime? leaveTime;
  bool? isLeft;
  DateTime? lastUpdateTime;

  LocalGroupMember();
  LocalGroupMember.fromSqlMap(Map<String, dynamic> map){
    id = map['id'];
    groupId = map['group_id'];
    memberRank = map['member_rank'];
    memberId = map['member_id'];
    memberRole = map['member_role'];
    if(map['join_time'] is int){
      joinTime = DateTime.fromMillisecondsSinceEpoch(map['join_time']);
    }
    if(map['leave_time'] is int){
      leaveTime = DateTime.fromMillisecondsSinceEpoch(map['leave_time']);
    }
    isLeft = (map['is_left'] ?? 0) > 0;
    if(map['last_update_time'] is int){
      lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(map['last_update_time']);
    }
  }
  Map<String, Object?> toSqlMap(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['group_id'] = groupId;
    map['member_rank'] = memberRank;
    map['member_id'] = memberId;
    map['member_remark'] = memberRemark;
    map['member_role'] = memberRole;
    map['join_time'] = joinTime?.millisecondsSinceEpoch;
    map['leave_time'] = leaveTime?.millisecondsSinceEpoch;
    map['is_left'] = isLeft == true ? 1 : 0;
    map['last_update_time'] = lastUpdateTime?.millisecondsSinceEpoch;
    return map;
  }

  LocalGroupMember.fromImGroupMember(ImGroupMember member){
    id = member.id;
    groupId = member.groupId;
    memberRank = member.memberRank;
    memberId = member.memberId;
    memberRemark = member.memberRemark;
    memberRole = member.memberRole;
    joinTime = member.joinTime;
    leaveTime = member.leaveTime;
    isLeft = member.isLeft;
    lastUpdateTime = DateTime.now();
  }
}


class LocalGroupMemberVo{

  int? id;
  int? groupId;
  int? memberRank;
  int? memberId;
  String? memberRemark;
  String? memberRole;
  String? memberHeadLocalPath;
  String? memberName;
  DateTime? joinTime;
  DateTime? leaveTime;
  bool? isLeft;
  DateTime? lastUpdateTime;

  LocalGroupMemberVo();
  LocalGroupMemberVo.fromSqlMap(Map<String, dynamic> map){
    id = map['id'];
    groupId = map['group_id'];
    memberRank = map['member_rank'];
    memberId = map['member_id'];
    memberRemark = map['member_remark'];
    memberRole = map['member_role'];
    memberHeadLocalPath = map['member_head_local_path'];
    memberName = map['member_name'];
    if(map['join_time'] is int){
      joinTime = DateTime.fromMillisecondsSinceEpoch(map['join_time']);
    }
    if(map['leave_time'] is int){
      leaveTime = DateTime.fromMillisecondsSinceEpoch(map['leave_time']);
    }
    isLeft = (map['is_left'] ?? 0) > 0;
    if(map['last_update_time'] is int){
      lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(map['last_update_time']);
    }
  }
}
