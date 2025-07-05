
class UserBlockUser {
  
  int? id;

  int? userId;
  
  int? blockId;

  String? username;

  String? userHead;

  DateTime? createdTime;

  UserBlockUser();

  UserBlockUser.fromJson(Map<String, dynamic> json){
    id = json['id'];
    userId = json['userId'];
    blockId = json['blockId'];
    username = json['username'];
    userHead = json['userHead'];
    if(json['createdTime'] is String){
      createdTime = DateTime.tryParse(json['createdTime']);
    }
  }
}
