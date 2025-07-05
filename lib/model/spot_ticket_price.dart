
class SpotTicketPriceModel{
  late int id;
  int? spotId;
  int? spotTicketId;
  int? price;
  int? stock;
  DateTime? day;
  SpotTicketPriceModel(this.id);

  SpotTicketPriceModel.fromJson(dynamic json) {
    id = json['id'] as int;
    spotId  = json['spotId'];
    spotTicketId = json['spotTicketId'];
    price = json['price'];
    stock = json['stock'];
    if(json['day'] != null){
      day = DateTime.tryParse(json['day']);
    }
  }
}
