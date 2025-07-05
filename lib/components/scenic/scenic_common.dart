
import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/simple_map_poi.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';

class ScenicTicketPrice{
  int? id;
  int? ticketId;
  int? settlePrice;
  DateTime? date;

  ScenicTicketPrice.fromJson(dynamic json){
    id = json['id'];
    ticketId = json['ticketId'];
    settlePrice = json['settlePrice'];
    if(json['date'] is String){
      date = DateTime.tryParse(json['date']);
    }
  }
}

class ScenicTicket{
  int? id;
  String? source;
  String? outerId;

  int? scenicId;
  String? name;
  int? marketPrice;
  int? settlePrice;
  int? advanceDay;
  String? advanceTime;

  String? bookNotice;
  String? refundChangeRule;
  String? costDescription;
  String? useDescription;
  String? otherDescription;

  int? minBuyCount;
  int? maxBuyCount;
  int? unitQuantity;
  int? contactInfoType;
  int? touristInfoType;
  String? supportCardTypes;

  List<ScenicTicketPrice>? priceCalendar;

  ScenicTicket.fromJson(dynamic json){
    id = json['id'];
    source = json['source'];
    outerId = json['outerId'];

    scenicId = json['scenicId'];
    name = json['name'];
    marketPrice = json['marketPrice'];
    settlePrice = json['settlePrice'];
    advanceDay = json['advanceDay'];
    advanceTime = json['advanceTime'];

    bookNotice = json['bookNotice'];
    refundChangeRule = json['refundChangeRule'];
    costDescription = json['costDescription'];
    useDescription = json['useDescription'];
    otherDescription = json['otherDescription'];

    minBuyCount = json['minBuyCount'];
    maxBuyCount = json['maxBuyCount'];
    unitQuantity = json['unitQuantity'];
    contactInfoType = json['contactInfoType'];
    touristInfoType = json['touristInfoType'];
    supportCardTypes = json['supportCardTypes'];

    if(json['priceCalendar'] != null){
      priceCalendar = [];
      for(dynamic item in json['priceCalendar']){
        priceCalendar!.add(ScenicTicketPrice.fromJson(item));
      }
    }
  }
}

class Scenic with StatisticMixin, BehaviorMixin{
  int? id;
  String? source;
  String? outerId;
  int? userId;

  String? name;
  String? cover;
  String? pics;
  String? city;
  String? address;

  double? latitude;
  double? longitude;
  int? stars;
  String? openTime;
  String? tags;
  String? description;
  String? recommend;
  String? bookNotice;

  int? price;
  List<ScenicTicket>? ticketList;

  Scenic();
  Scenic.fromJson(dynamic json){
    id = json['id'];
    source = json['source'];
    outerId = json['outerId'];
    userId = json['userId'];

    name = json['name'];
    cover = json['cover'];
    pics = json['pics'];
    city = json['city'];
    address = json['address'];

    latitude = json['latitude'];
    longitude = json['longitude'];
    stars = json['stars'];
    openTime = json['openTime'];
    tags = json['tags'];
    description = json['description'];
    recommend = json['recommend'];
    bookNotice = json['bookNotice'];

    price = json['price'];

    statisticByJson(json);
    behaviorByJson(json);

    if(json['ticketList'] is List){
      ticketList = [];
      for(dynamic item in json['ticketList']){
        ticketList!.add(ScenicTicket.fromJson(item));
      }
    }
  }

  bool likeTheSame(Scenic other){
    return city == other.city && name == other.name;
  }
}

class SimpleScenic implements SimpleMapPoi{
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

  SimpleScenic.fromJson(dynamic json){
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
    price = json['price'];
  }

  SimpleScenic.fromGaode(dynamic json){
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
    if(business != null){
      if(business['rating'] is String){
        score = double.tryParse(business['rating']);
      }
      if(business['cost'] is String){
        double? priceDouble = double.tryParse(business['cost']);
        if(priceDouble != null){
          price = (priceDouble * 100).toInt();
        }
      }
    }
    
    dynamic photos = json['photos'];
    if(photos != null){
      List<String> photoList = [];
      for(dynamic item in photos){
        photoList.add(item['url']);
      }
      if(photoList.isNotEmpty){
        cover = photoList.first;
      }
    }
  }
}

enum ContactInfoType{
  none,
  namePhone,
  namePhonwCard
}

extension ContactInfoTypeExt on ContactInfoType{
  int getNum(){
    switch(this){
      case ContactInfoType.none:
        return 0;
      case ContactInfoType.namePhone:
        return 1;
      case ContactInfoType.namePhonwCard:
        return 2;
    }
  }
  static ContactInfoType? getType(int num){
    for(ContactInfoType type in ContactInfoType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

enum TouristInfoType{
  none,
  singleNamePhone,
  singleNamePhoneCard,
  everyNamePhone,
  everyNamePhoneCard
}

extension TouristInfoTypeExt on TouristInfoType{
  int getNum(){
    switch(this){
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
  static TouristInfoType? getType(int num){
    for(TouristInfoType type in TouristInfoType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}