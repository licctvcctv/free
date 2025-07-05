
class OnlineMusic{
  int? id;
  int? useNum;
  DateTime? createTime;
  String? path;
  String? name;
  String? artist;

  OnlineMusic();
  OnlineMusic.fromJson(dynamic json){
    id = json['id'];
    useNum = json['useNum'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
    path = json['path'];
    name = json['name'];
    artist = json['artist'];
  }
}
