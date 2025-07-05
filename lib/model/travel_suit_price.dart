class TravelSuitPriceModel {
  late int id;
  int? travelId;
  int? travelSuitId;
  int? price;
  int? oldPrice;
  int? childPrice;
  DateTime? day;
  int? stock;

  TravelSuitPriceModel(this.id, suitId, {int? price});

  TravelSuitPriceModel.fromJson(dynamic json) {
    id = json['id'] as int;
    travelId = json['travelId'];
    travelSuitId = json['travelSuitId'];
    price = json['price'];
    oldPrice = json['oldPrice'];
    childPrice = json['childPrice'];
    if(json['day'] is String){
      day = DateTime.tryParse(json['day']);
    }
    stock = json['stock'];
  }
}
