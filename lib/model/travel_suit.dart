class TravelSuitModel {
  late int id;
  int? travelId;
  int? personNum;
  String? name;
  String? description;
  String? rendezvousTime;
  String? rendezvousLocation;
  String? supportCardTypes;

  TravelSuitModel(this.id);

  TravelSuitModel.fromJson(dynamic json) {
    id = json['id'] as int;
    travelId = json['travelId'];
    personNum = json['napersonNumme'];
    name = json['name'];
    description = json['description'];
    rendezvousTime = json['rendezvousTime'];
    rendezvousLocation = json['rendezvousLocation'];
    supportCardTypes = json['supportCardTypes'];
  }
}
