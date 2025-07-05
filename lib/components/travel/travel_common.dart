import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/simple_map_poi.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';

class SimpleTravel implements SimpleMapPoi {
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

  SimpleTravel.fromJson(dynamic json) {
    id = json['id'];
    source = json['source'];
    outerId = json['outerId'];

    name = json['name'];
    city = json['city'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];

    stars = json['stars'];
    score = json['score'];
    cover = json['cover'];
    price = json['minPrice'];
  }

  SimpleTravel.fromGaode(dynamic json) {
    source = 'gaode';
    outerId = json['id'];

    name = json['name'];
    city = json['cityname'];
    address = json['address'];

    String location = json['location'];
    var locationList = location.split(",");
    latitude = double.parse(locationList[1]);
    longitude = double.parse(locationList[0]);

    dynamic business = json['business'];
    if (business != null) {
      if (business['rating'] is String) {
        score = double.tryParse(business['rating']);
      }
      if (business['cost'] is String) {
        double? priceDouble = double.tryParse(business['cost']);
        if (priceDouble != null) {
          price = (priceDouble * 100).toInt();
        }
      }
    }

    dynamic photos = json['photos'];
    if (photos != null) {
      List<String> photoList = [];
      for (dynamic item in photos) {
        photoList.add(item['url']);
      }
      if (photoList.isNotEmpty) {
        cover = photoList.first;
      }
    }
  }
}

enum ContactInfoType { none, namePhone, namePhonwCard }

extension ContactInfoTypeExt on ContactInfoType {
  int getNum() {
    switch (this) {
      case ContactInfoType.none:
        return 0;
      case ContactInfoType.namePhone:
        return 1;
      case ContactInfoType.namePhonwCard:
        return 2;
    }
  }

  static ContactInfoType? getType(int num) {
    for (ContactInfoType type in ContactInfoType.values) {
      if (type.getNum() == num) {
        return type;
      }
    }
    return null;
  }
}

enum TouristInfoType {
  none,
  singleNamePhone,
  singleNamePhoneCard,
  everyNamePhone,
  everyNamePhoneCard
}

extension TouristInfoTypeExt on TouristInfoType {
  int getNum() {
    switch (this) {
      case TouristInfoType.none:
        return 0;
      case TouristInfoType.singleNamePhone:
        return 1;
      case TouristInfoType.singleNamePhoneCard:
        return 2;
      case TouristInfoType.everyNamePhone:
        return 3;
      case TouristInfoType.everyNamePhoneCard:
        return 4;
    }
  }

  static TouristInfoType? getType(int num) {
    for (TouristInfoType type in TouristInfoType.values) {
      if (type.getNum() == num) {
        return type;
      }
    }
    return null;
  }
}

class Travel with StatisticMixin, BehaviorMixin {
  int? id;
  String? source;
  String? outerId;
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
  int? minPrice;
  DateTime? minPriceUpdateBate;
  double? lng;
  double? lat;
  String? video;
  String? pics;
  String? description;
  String? bookNotice;
  DateTime? createTime;
  List<TravelSuit>? suitList;
  Travel(this.id);
  Travel.fromJson(dynamic json) {
    id = json['id'];
    source = json['source'];
    outerId = json['outerId'];
    userId = json['userId'];
    name = json['name'];
    keywords = json['keywords'];
    openCloseTimes = json['openCloseTimes'];
    province = json['province'];
    city = json['city'];
    destProvince = json['destProvince'];
    destCity = json['destCity'];
    isCancelAllowed = json['isCancelAllowed'];
    dayNum = json['dayNum'];
    nightNum = json['nightNum'];
    orderBeforeDays = json['orderBeforeDays'];
    minPrice = json['minPrice'];
    if(json['openDate'] != null){
      minPriceUpdateBate = DateTime.tryParse(json['minPriceUpdateBate']);
    }
    lng = json['lng'];
    lat = json['lat'];
    video = json['video'];
    pics = json['pics'];
    description = json['description'];
    bookNotice = json['bookNotice'];
    if(json['updateTime'] != null){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if (json['suitList'] != null) {
      suitList = [];
      for (dynamic item in json['suitList']) {
        suitList!.add(TravelSuit.fromJson(item));
      }
    }
    statisticByJson(json);
    behaviorByJson(json);
  }
}

class TravelSuit {
  int? id;
  int? travelId;
  int? personNum;
  String? name;
  String? description;
  String? rendezvousTime;
  String? rendezvousLocation;
  String? supportCardTypes;
  int? dayPrice;

  TravelSuit(this.id);

  TravelSuit.fromJson(dynamic json) {
    id = json['id'] as int;
    travelId = json['travelId'];
    personNum = json['personNum'];
    name = json['name'];
    description = json['description'];
    rendezvousTime = json['rendezvousTime'];
    rendezvousLocation = json['rendezvousLocation'];
    supportCardTypes = json['supportCardTypes'];
    dayPrice = json['dayPrice'];
  }
}

class TravelSuitPrice{
  int? id;
  int? travelId;
  int? travelSuitId;
  int? price;
  int? oldPrice;
  int? childPrice;
  DateTime? day;
  int? stock;

  TravelSuitPrice();
  TravelSuitPrice.fromJson(dynamic json){
    id = json['id'];
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
