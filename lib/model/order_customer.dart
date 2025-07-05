
class OrderCustomer{

  late String name;
  late String phone;
  late String identityNum;

  OrderCustomer(this.name,this.phone,this.identityNum);
  OrderCustomer.fromJson(dynamic json){
    name = json['name'];
    phone = json['phone'];
    identityNum = json['identityNum'];
  }

  Map<String, dynamic> toJson(){
    Map<String, dynamic> map = {};
    map['name'] = name;
    map['phone'] = phone;
    map['identityNum'] = identityNum;
    return map;
  }
}
