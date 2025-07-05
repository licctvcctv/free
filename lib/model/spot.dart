import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/spot_ticket.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';

class SpotModel with StatisticMixin, BehaviorMixin{
  late int id;
  String? name;
  int? userId;
  String? keywords;
  String? openCloseTimes;
  String? province;
  String? city;
  String? district;
  String? address;
  String? addressFull;
  String? pics;
  String? video;
  String? description;
  String? bookNotice;
  double? lng;
  double? lat;
  int? minPrice;
  List<SpotTicketModel>? spotTicketList;

  SpotModel(this.id);

  SpotModel.fromJson(dynamic json) {
    id = json['id'] as int;
    name = json['name'];
    userId = json['userId'];
    keywords = json['keywords'];
    openCloseTimes = json['openCloseTimes'];
    province = json['province'];
    city = json['city'];
    district = json['district'];
    address = json['address'];
    pics = json['pics'];
    video = json['video'];
    description = json['description'];
    bookNotice = json['bookNotice'];
    lng = json['lng'];
    lat = json['lat'];
    minPrice = json['minPrice'];
    showNum = json['showNum'];

    spotTicketList = [];
    for(dynamic item in json['spotTicketList'] ?? []){
      spotTicketList!.add(SpotTicketModel.fromJson(item));
    }

    statisticByJson(json);
    behaviorByJson(json);
  }
}
