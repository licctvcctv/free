
class UserFriend{

  int id;
  int? userId;
  int? friendId;
  String? friendRemark;
  String? friendGroup;
  DateTime? createTime;
  DateTime? updateTime;

  String? name;
  String? head;

  UserFriend(this.id);
  UserFriend.fromJson(dynamic json): id = json['id']{
    userId = json['userId'];
    friendId = json['friendId'];
    friendRemark = json['friendRemark'];
    friendGroup = json['friendGroup'];
    if(json['createTime'] != null){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] != null){
      updateTime = DateTime.tryParse(json['updateTime']);
    }
    name = json['name'];
    head = json['head'];
  }
  UserFriend.fromSqlMap(dynamic json): id = json['id']{
    userId = json['user_id'];
    friendId = json['friend_id'];
    friendRemark = json['friend_remark'];
    friendGroup = json['friend_group'];
    if(json['create_time'] != null){
      createTime = DateTime.fromMillisecondsSinceEpoch(json['create_time']);
    }
    if(json['update_time'] != null){
      updateTime = DateTime.fromMillisecondsSinceEpoch(json['update_time']);
    }
    name = json['name'];
    head = json['head'];
  }
  Map<String, Object?> toSqlMap(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['user_id'] = userId;
    map['friend_id'] = friendId;
    map['friend_remark'] = friendRemark;
    map['friend_group'] = friendGroup;
    map['create_time'] = createTime?.millisecondsSinceEpoch;
    map['update_time'] = updateTime?.millisecondsSinceEpoch;
    map['name'] = name;
    map['head'] = head;
    return map;
  }
}
