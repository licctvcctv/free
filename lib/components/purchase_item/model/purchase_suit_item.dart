
class PurchaseSuitItem{
  
  int? id;

  int? itemTypeId;

  int? count;

  String? name;

  String? description;

  String? imageUrl;

  PurchaseSuitItem();

  PurchaseSuitItem.fromJson(Map<String, dynamic> json){
    id = json['id'];
    itemTypeId = json['itemTypeId'];
    count = json['count'];
    name = json['name'];
    description = json['description'];
    imageUrl = json['imageUrl'];
  }
}
