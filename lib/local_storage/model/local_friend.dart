
import 'package:freego_flutter/components/friend_neo/user_friend.dart';

class LocalFriend{

  int? id;
  int? userId;
  String? friendRemark;
  String? friendGroup;
  DateTime? lastUpdateTime;

  LocalFriend();

  Map<String, Object?> toSqlMap(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['user_id'] = userId;
    map['friend_remark'] = friendRemark;
    map['friend_group'] = friendGroup;
    map['last_update_time'] = lastUpdateTime?.millisecondsSinceEpoch;
    return map;
  }

  LocalFriend.fromSqlMap(Map<String, dynamic> map){
    id = map['id'];
    userId = map['user_id'];
    friendRemark = map['friend_remark'];
    friendGroup = map['friend_group'];
    if(map['last_update_time'] is int){
      lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(map['last_update_time']);
    }
  }

  LocalFriend.fromUserFriend(UserFriend userFriend){
    id = userFriend.id;
    userId = userFriend.friendId;
    friendRemark = userFriend.friendRemark;
    friendGroup = userFriend.friendGroup;
    lastUpdateTime = DateTime.now();
  }
}

class LocalFriendVo{

  int? id;
  int? friendId;
  String? friendRemark;
  String? friendName;
  String? friendHeadLocal;
  String? friendGroup;
  DateTime? lastUpdateTime;

  LocalFriendVo();

  LocalFriendVo.fromSqlMap(Map<String, dynamic> map){
    id = map['id'];
    friendId = map['friend_id'];
    friendRemark = map['friend_remark'];
    friendName = map['friend_name'];
    friendHeadLocal = map['friend_head_local'];
    friendGroup = map['friend_group'];
    if(map['last_update_time'] is int){
      lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(map['last_update_time']);
    }
  }

}
