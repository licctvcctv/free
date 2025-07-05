
class UserPurchaseItem{

  int? id;

  int? userId;

  int? count;

  bool? isValid;

  DateTime? expiredTime;

  int? itemTypeId;

  String? name;

  String? description;

  String? imageUrl;

  String? beanName;

  UserPurchaseItem();

  UserPurchaseItem.fromJson(Map<String, dynamic> json){
    id = json['id'];
    userId = json['userId'];
    count = json['count'];
    isValid = json['isValid'];
    if(json['expiredTime'] is String){
      expiredTime = DateTime.tryParse(json['expiredTime']);
    }
    itemTypeId = json['itemTypeId'];
    name = json['name'];
    description = json['description'];
    imageUrl = json['imageUrl'];
    beanName = json['beanName'];
  }
}
