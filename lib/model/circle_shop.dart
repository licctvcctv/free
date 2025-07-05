import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';

class CircleShopModel with StatisticMixin, BehaviorMixin {
  late int cid;
  String? name;
  int? userId;
  String? pics;
  String? phone;
  String? openCloseTime;
  String? description;
  String? location;
  double? lng;
  double? lat;
  List<String> picList = [];
  List<String> tagList = [];

  CircleShopModel(this.cid);
  CircleShopModel.fromJson(dynamic json) {
    cid = json['cid'];
    pics = json['pics'];
    name = json['name'];
    userId = json['userId'];
    openCloseTime = json['openCloseTime'];
    description = json['description'];
    phone = json['phone'];
    location = json['location'];
    lng = json['lng'];
    lat = json['lat'];
    picList = pics != null ? pics!.split(',') : picList;

    statisticByJson(json);
    behaviorByJson(json);
  }
}
