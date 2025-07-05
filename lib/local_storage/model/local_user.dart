
class LocalUser{
  int? id;
  String? name;
  String? headUrl;
  String? headLocalPath;
  DateTime? lastUpdateTime;

  LocalUser();
  LocalUser.fromSqlMap(Map<String, dynamic> map){
    id = map['id'];
    name = map['name'];
    headUrl = map['head_url'];
    headLocalPath = map['head_local_path'];
    if(map['last_update_time'] is int){
      lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(map['last_update_time']);
    }
  }
  LocalUser.fromJson(dynamic json){
    id = json['id'];
    name = json['name'];
    headUrl = json['headUrl'];
  }
  Map<String, dynamic> toSqlMap(){
    Map<String, dynamic> map = {};
    map['id'] = id;
    map['name'] = name;
    map['head_url'] = headUrl;
    map['head_local_path'] = headLocalPath;
    map['last_update_time'] = lastUpdateTime?.millisecondsSinceEpoch;
    return map;
  }
}
