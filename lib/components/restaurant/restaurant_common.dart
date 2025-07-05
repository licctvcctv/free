import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/simple_map_poi.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';

class Restaurant with StatisticMixin, BehaviorMixin {
  int? id;
  String? source;
  String? outerId;
  int? userId;
  String? name;
  String? keywords;
  String? openCloseTimes;
  bool? hasWifi;
  String? foodType;
  String? recommendFood;
  int? averagePrice;
  String? phone;
  String? province;
  String? city;
  String? district;
  String? address;
  String? pics;
  String? video;
  String? cover;
  String? description;
  String? bookNotice;
  double? lat;
  double? lng;
  DateTime? openDate;
  DateTime? createTime;
  DateTime? updateTime;
  List<RestaurantDish>? dishList;
  Restaurant(this.id);
  Restaurant.fromJson(dynamic json) {
    id = json['id'];
    source = json['source'];
    outerId = json['outerId'];
    userId = json['userId'];
    name = json['name'];
    keywords = json['keywords'];
    openCloseTimes = json['openCloseTimes'];
    hasWifi = json['hasWifi'] != null && json['hasWifi'] > 0;
    foodType = json['foodType'];
    recommendFood = json['recommendFood'];
    averagePrice = json['averagePrice'];
    phone = json['phone'];
    province = json['province'];
    city = json['city'];
    district = json['district'];
    address = json['address'];
    pics = json['pics'];
    video = json['video'];
    cover = json['cover'];
    description = json['description'];
    bookNotice = json['bookNotice'];
    lng = json['lng'];
    lat = json['lat'];
    showNum = json['showNum'];
    if (json['openDate'] != null) {
      openDate = DateTime.tryParse(json['openDate']);
    }
    if (json['createTime'] != null) {
      createTime = DateTime.tryParse(json['createTime']);
    }
    if (json['updateTime'] != null) {
      updateTime = DateTime.tryParse(json['updateTime']);
    }
    if (json['dishList'] != null) {
      dishList = [];
      for (dynamic item in json['dishList']) {
        dishList!.add(RestaurantDish.fromJson(item));
      }
    }
    statisticByJson(json);
    behaviorByJson(json);
  }
}

class RestaurantDish {
  late int id;
  int? restaurantId;
  String? name;
  String? pic;
  int? price;
  int? priceOld;
  String? tags;
  String? description;
  DateTime? createTime;
  DateTime? updateTime;
  RestaurantDish(this.id);
  RestaurantDish.fromJson(dynamic json) {
    id = json['id'];
    restaurantId = json['restaurantId'];
    name = json['name'];
    pic = json['pic'];
    price = json['price'];
    priceOld = json['priceOld'];
    tags = json['tags'];
    description = json['description'];
    createTime = DateTime.parse(json['createTime']);
    updateTime = DateTime.parse(json['updateTime']);
  }
}

class SimpleRestaurant implements SimpleMapPoi {
  @override
  String? source;
  @override
  String? outerId;
  @override
  int? id;

  @override
  String? name;
  @override
  String? city;
  @override
  String? address;
  @override
  double? latitude;
  @override
  double? longitude;

  @override
  int? stars;
  @override
  double? score;
  @override
  String? cover;
  @override
  int? price;

  SimpleRestaurant.fromJson(dynamic json) {
    id = json['id'];
    source = json['source'];
    outerId = json['outerId'];

    name = json['name'];
    city = json['city'];
    address = json['address'];
    latitude = json['lat'];
    longitude = json['lng'];

    stars = json['stars'];
    score = json['score'];
    cover = json['cover'];
    price = json['averagePrice'];
  }
}

enum DiningType{
  inStore,
  packed
}

extension DiningTypeExt on DiningType{

  int getNum(){
    switch(this){
      case DiningType.inStore:
        return 1;
      case DiningType.packed:
        return 2;
    }
  }

  String getText(){
    switch(this){
      case DiningType.inStore:
        return 'dine-in';
      case DiningType.packed:
        return 'take-out';
    }
  }

  static DiningType? getType(int num){
    for(DiningType type in DiningType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }

  static DiningType? getTypeByName(String name){
    for(DiningType type in DiningType.values){
      if(type.getText() == name){
        return type;
      }
    }
    return null;
  }
}
