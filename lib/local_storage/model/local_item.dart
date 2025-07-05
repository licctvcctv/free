
class LocalItem{

  int? id;
  String? name;
  String? imageUrl;
  String? imageLocalPath;
  DateTime? lastUpdateTime;

  LocalItem();
  LocalItem.fromSqlMap(Map<String, dynamic> map){
    id = map['id'];
    name = map['name'];
    imageUrl = map['image_url'];
    imageLocalPath = map['image_local_path'];
    if(map['last_update_time'] is int){
      lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(map['last_update_time']);
    }
  }
  Map<String, dynamic> toSqlMap(){
    Map<String, dynamic> map = {};
    map['id'] = id;
    map['name'] = name;
    map['image_url'] = imageUrl;
    map['image_local_path'] = imageLocalPath;
    map['last_update_time'] = lastUpdateTime?.millisecondsSinceEpoch;
    return map;
  }
  LocalItem.fromJson(dynamic json){
    id = json['id'];
    name = json['name'];
    imageUrl = json['imageUrl'];
  }
}
