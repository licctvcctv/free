
class PurchaseSuit{

  int? id;

  String? name;

  String? description;

  int? price;

  String? imageUrl;

  bool? isValid;

  int? buyLimit;

  int? buyLimitSingle;

  DateTime? validTime;

  DateTime? expiredTime;

  PurchaseSuit();

  PurchaseSuit.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    imageUrl = json['imageUrl'];
    isValid = json['isValid'];
    buyLimit = json['buyLimit'];
    buyLimitSingle = json['buyLimitSingle'];
    if(json['validTime'] is String){
      validTime = DateTime.tryParse(json['validTime']);
    }
    if(json['expiredTime'] is String){
      expiredTime = DateTime.tryParse(json['expiredTime']);
    }
  }
}
