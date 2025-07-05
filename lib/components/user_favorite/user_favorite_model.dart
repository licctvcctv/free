
class UserFavorite{
  int? id;
  int? userId;
  int? productId;
  int? productType;
  String? name;
  String? cover;
  DateTime? createTime;

  UserFavorite.fromJson(dynamic json){
    id = json['id'];
    userId = json['userId'];
    productId = json['productId'];
    productType = json['productType'];
    name = json['name'];
    cover = json['cover'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
  }
}
