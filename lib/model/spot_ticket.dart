
class SpotTicketModel{
  late int id;
  int? spotId;
  String? spotName;
  double? spotLat;
  double? spotLng;
  int? userId;
  String? name;
  String? description;

  DateTime? createTime;
  DateTime? updateTime;

  String? merchantName;
  String? merchantHead;

  int? price;
  int? stock;
  DateTime? date;

  SpotTicketModel.fromJson(dynamic json) {
    id = json['id'] as int;
    spotId = json['spotId'];
    spotName = json['spotName'];
    spotLat = json['spotLat'];
    spotLng = json['spotLng'];
    userId = json['userId'];
    name = json['name'];
    description = json['description'];

    if(json['createTime'] != null){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] != null){
      updateTime = DateTime.tryParse(json['updateTime']);
    }

    merchantName = json['merchantName'];
    merchantHead = json['merchantHead'];

    price = json['price'];
    stock = json['stock'];
    if(json['date'] != null){
      date = DateTime.tryParse(json['date']);
    }
  }
}
