import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';

class TravelModel with StatisticMixin, BehaviorMixin {
  late int id;
  int? userId;
  String? name;
  String? keywords;
  String? openCloseTimes;
  String? province;
  String? city;
  String? destProvince;
  String? destCity;
  int? isCancelAllowed;
  int? dayNum;
  int? nightNum;
  int? orderBeforeDays;
  String? pics;
  String? video;
  String? description;
  String? bookNotice;
  String? lng;
  String? lat;
  int? minPrice;
  String? createTime;
  String? updateTime;
  List<String>? picList = [];
  TravelModel(this.id);
  TravelModel.fromJson(dynamic json) {
    id = json['id'] as int;
    name = json['name'];
    userId = json['userId'];
    keywords = json['keywords'];
    openCloseTimes = json['openCloseTimes'];
    province = json['province'];
    city = json['city'];
    isCancelAllowed = json['isCancelAllowed'];
    dayNum = json['dayNum'];
    nightNum = json['nightNum'];
    orderBeforeDays = json['orderBeforeDays'];
    pics = json['pics'];
    video = json['video'];
    description = json['description'];
    bookNotice = json['bookNotice'];
    lng = json['lng'];
    lat = json['lat'];
    showNum = json['showNum'];
    picList = pics != null ? pics!.split(',') : [];
    minPrice = json['minPrice'];

    statisticByJson(json);
    behaviorByJson(json);
  }
}
