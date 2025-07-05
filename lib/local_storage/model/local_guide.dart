
class LocalGuide{
  int? id;
  String? name;
  String? coverUrl;
  String? coverLocalPath;
  DateTime? lastUpdateTime;

  LocalGuide();
  LocalGuide.fromSqlMap(Map<String, dynamic> map){
    
    id = map['id'];
    name = map['name'];
    coverUrl = map['cover_url'];
    coverLocalPath = map['cover_local_path'];
    if(map['last_update_time'] is int){
      lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(map['last_update_time']);
    }
  }
  Map<String, dynamic> toSqlMap(){
    Map<String, dynamic> map = {};
    map['id'] = id;
    map['name'] = name;
    map['cover_url'] = coverUrl;
    map['cover_local_path'] = coverLocalPath;
    map['last_update_time'] = lastUpdateTime?.millisecondsSinceEpoch;
    return map;
  }
  LocalGuide.fromJson(dynamic json){
    id = json['id'];
    name = json['name'];
    coverUrl = json['coverUrl'];
  }
}