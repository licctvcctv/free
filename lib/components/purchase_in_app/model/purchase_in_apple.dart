
class PurchaseInApple{

  int? id;
  String? purchaseId;
  String? name;
  String? description;
  String? imageUrl;
  String? effectBean;
  int? scale;
  DateTime? createdTime;

  PurchaseInApple();

  PurchaseInApple.fromJson(Map<String, dynamic> json){
    id = json['id'];
    purchaseId = json['purchaseId'];
    name = json['name'];
    description = json['description'];
    imageUrl = json['imageUrl'];
    effectBean = json['effectBean'];
    scale = json['scale'];
    if(json['createdTime'] is String){
      createdTime = DateTime.tryParse(json['createdTime']);
    }
  }
}
