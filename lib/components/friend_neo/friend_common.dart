
class SimpleUser{
  int? id;
  String? head;
  String? name;
  bool? isFriend;
  SimpleUser();
  SimpleUser.fromJson(dynamic json){
    id = json['id'];
    head = json['head'];
    name = json['name'];
    isFriend = json['isFriend'];
  }
}
