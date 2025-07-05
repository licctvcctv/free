
class PrePayInfo{

  String? serial;

  int? price;

  DateTime? payLimitTime;

  PrePayInfo();

  PrePayInfo.fromJson(Map<String, dynamic> json){
    serial = json['serial'];
    price = json['price'];
    if(json['payLimitTime'] is String){
      payLimitTime = DateTime.tryParse(json['payLimitTime']);
    }
  }
}