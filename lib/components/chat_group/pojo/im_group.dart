
class ImGroup{

  int? id;
  int? ownnerId;
  String? type;
  String? name;
  String? description;
  String? remark;
  String? avatar;
  String? announce;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? memberCount;
  String? role;
  int? rank;

  ImGroup();
  ImGroup.fromJson(dynamic json){
    id = json['id'];
    ownnerId = json['ownnerId'];
    type = json['type'];
    name = json['name'];
    description = json['description'];
    remark = json['remark'];
    avatar = json['avatar'];
    announce = json['announce'];
    if(json['createdAt'] is String){
      createdAt = DateTime.tryParse(json['createdAt']);
    }
    if(json['updatedAt'] is String){
      updatedAt = DateTime.tryParse(json['updatedAt']);
    }
    memberCount = json['memberCount'];
    role = json['role'];
    rank = json['rank'];
  }

}
