
import 'package:freego_flutter/components/chat_group/pojo/im_group.dart';

class LocalGroup{

  int? id;
  int? ownnerId;
  String? type;
  String? name;
  String? description;
  String? remark;
  String? avatarUrl;
  String? avatarLocalPath;
  String? announce;
  int? memberCount;
  int? rank;
  bool? isBanned;
  DateTime? createdAt;
  DateTime? lastUpdateTime;

  LocalGroup();
  
  LocalGroup.fromSqlMap(Map<String, dynamic> map){
    id = map['id'];
    ownnerId = map['ownner_id'];
    type = map['type'];
    name = map['name'];
    description = map['description'];
    remark = map['remark'];
    avatarUrl = map['avatar_url'];
    avatarLocalPath = map['avatar_local_path'];
    announce = map['announce'];
    memberCount = map['member_count'];
    rank = map['rank'];
    isBanned = (map['isBanned'] ?? 0) > 0;
    if(map['created_at'] is int){
      createdAt = DateTime.fromMillisecondsSinceEpoch(map['created_at']);
    }
    if(map['last_update_time'] is int){
      lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(map['last_update_time']);
    }
  }
  Map<String, Object?> toSqlMap(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['ownner_id'] = ownnerId;
    map['type'] = type;
    map['name'] = name;
    map['description'] = description;
    map['remark'] = remark;
    map['avatar_url'] = avatarUrl;
    map['avatar_local_path'] = avatarLocalPath;
    map['announce'] = announce;
    map['member_count'] = memberCount;
    map['rank'] = rank;
    map['is_banned'] = isBanned == true ? 1 : 0;
    map['created_at'] = createdAt?.millisecondsSinceEpoch;
    map['last_update_time'] = lastUpdateTime?.millisecondsSinceEpoch;
    return map;
  }
  LocalGroup.fromImGroup(ImGroup group){
    id = group.id;
    ownnerId = group.ownnerId;
    type = group.type;
    name = group.name;
    description = group.description;
    remark = group.remark;
    avatarUrl = group.avatar;
    announce = group.announce;
    memberCount = group.memberCount;
    rank = group.rank;
    createdAt = group.createdAt;
    lastUpdateTime = DateTime.now();
  }

  void clone(LocalGroup group){
    id = group.id;
    ownnerId = group.ownnerId;
    type = group.type;
    name = group.name;
    description = group.description;
    remark = group.remark;
    avatarUrl = group.avatarUrl;
    avatarLocalPath = group.avatarLocalPath;
    announce = group.announce;
    memberCount = group.memberCount;
    rank = group.rank;
    isBanned = group.isBanned;
    createdAt = group.createdAt;
    lastUpdateTime = group.lastUpdateTime;
  }
}
