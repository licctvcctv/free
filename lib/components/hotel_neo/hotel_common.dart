
import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/simple_map_poi.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';

class HotelChamberPlanPrice{
  int? id;
  int? planId;

  DateTime? date;
  int? price;
  int? stock;

  HotelChamberPlanPrice.fromJson(dynamic json){
    id = json['id'];
    planId = json['planId'];
    if(json['date'] is String){
      date = DateTime.tryParse(json['date']);
    }
    price = json['price'];
    stock = json['stock'];
  }
}

class HotelChamberPlan{
  int? id;
  int? chamberId;
  String? name;

  int? payType;
  String? breakfast;
  int? averagePrice;

  String? cancelRuleName;
  int? cancelRuleType;
  String? cancelRuleDesc;
  String? cancelRuleLatestTime;

  List<HotelChamberPlanPrice>? priceList;

  String? ratePlanId;

  HotelChamberPlan.fromJson(dynamic json){
    id = json['id'];
    chamberId = json['chamberId'];
    name = json['name'];

    payType = json['payType'];
    breakfast = json['breakfast'];
    averagePrice = json['averagePrice'];

    cancelRuleName = json['cancelRuleName'];
    cancelRuleType = json['cancelRuleType'];
    cancelRuleDesc = json['cancelRuleDesc'];
    cancelRuleLatestTime = json['cancelRuleDesc'];
  
    if(json['priceList'] is List){
      priceList = [];
      for(dynamic item in json['priceList']){
        priceList!.add(HotelChamberPlanPrice.fromJson(item));
      }
    }

    ratePlanId = json['ratePlanId'];
  }

  get checkInDate => null;

  get checkOutDate => null;
}

class HotelChamberFacility{
  int? id;
  int? chamberId;

  String? name;
  int? status;

  HotelChamberFacility.fromJson(dynamic json){
    id = json['id'];
    chamberId = json['chamberId'];
    name = json['name'];
    status = json['status'];
  }
}

class HotelChamberPicture{
  int? id;
  int? chamberId;

  String? path;
  String? name;

  HotelChamberPicture.fromJson(dynamic json){
    id = json['id'];
    chamberId = json['chamberId'];
    path = json['path'];
    name = json['name'];
  }
}

class HotelChamber{
  int? id;
  String? source;
  String? outerId;

  int? hotelId;
  String? name;
  String? area;
  String? capacity;
  String? floors;
  String? bedType;

  List<HotelChamberPlan>? planList;

  List<HotelChamberPicture>? pictureList;
  List<HotelChamberFacility>? facilityList;

  HotelChamber.fromJson(dynamic json){
    id = json['id'];
    source = json['source'];
    outerId = json['outerId'];

    hotelId = json['hotelId'];
    name = json['name'];
    area = json['area'];
    capacity = json['capacity'];
    floors = json['floors'];
    bedType = json['bedType'];

    if(json['planList'] is List){
      planList = [];
      for(dynamic item in json['planList']){
        planList!.add(HotelChamberPlan.fromJson(item));
      }
    }
    if(json['pictureList'] is List){
      pictureList = [];
      for(dynamic item in json['pictureList']){
        pictureList!.add(HotelChamberPicture.fromJson(item));
      }
    } 
    if(json['facilityList'] is List){
      facilityList = [];
      for(dynamic item in json['facilityList']){
        facilityList!.add(HotelChamberFacility.fromJson(item));
      }
    }
  }
}

class Hotel with StatisticMixin, BehaviorMixin{
  int? id;
  String? source;
  String? outerId;

  int? userId;
  String? name;
  String? city;
  String? address;
  int? stars;
  String? phone;
  String? openDate;
  String? decorationDate;
  String? description;

  double? latitude;
  double? longitude;

  String? cover;
  int? price;

  List<HotelPic>? pictureList;
  List<HotelService>? serviceList;
  List<HotelFacility>? facilityList;

  List<HotelChamber>? chamberList;

  Hotel();
  Hotel.fromJson(dynamic json){
    id = json['id'];
    source = json['source'];
    outerId = json['outerId'];
    userId = json['userId'];
    
    name = json['name'];
    city = json['city'];
    address = json['address'];
    stars = json['stars'];
    phone = json['phone'];
    openDate = json['openDate'];
    decorationDate = json['decorationDate'];
    description = json['description'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    cover = json['cover'];
    price = json['price'];

    statisticByJson(json);
    behaviorByJson(json);

    if(json['pictureList'] is List){
      pictureList = [];
      for(dynamic item in json['pictureList']){
        pictureList!.add(HotelPic.fromJson(item));
      }
    }
    if(json['serviceList'] is List){
      serviceList = [];
      for(dynamic item in json['serviceList']){
        serviceList!.add(HotelService.fromJson(item));
      }
    }
    if(json['facilityList'] is List){
      facilityList = [];
      for(dynamic item in json['facilityList']){
        facilityList!.add(HotelFacility.fromJson(item));
      }
    }
    if(json['chamberList'] is List){
      chamberList = [];
      for(dynamic item in json['chamberList']){
        chamberList!.add(HotelChamber.fromJson(item));
      }
    }
  }

  bool likeTheSame(Hotel other){
    return city == other.city && name == other.name;
  }
}

class HotelPic{
  String? path;
  String? url;
  HotelPic.fromJson(dynamic json){
    path = json['path'];
    url = json['url'];
  }
}

class HotelService{
  String? name;
  int? status;
  HotelService.fromJson(dynamic json){
    name = json['name'];
    status = json['status'];
  }
}

class HotelFacility{
  String? name;
  int? status;
  HotelFacility.fromJson(dynamic json){
    name = json['name'];
    status = json['status'];
  }
}

enum HotelItemStatus{
  none, // 无
  full, // 有
  unknown, // 不确定
  partial // 部分有
}

extension HotelItemStatusExt on HotelItemStatus{
  int getNum(){
    switch(this){
      case HotelItemStatus.none:
        return 0;
      case HotelItemStatus.full:
        return 1;
      case HotelItemStatus.unknown:
        return 2;
      case HotelItemStatus.partial:
        return 3;
    }
  }
  static HotelItemStatus? getStatus(int num){
    for(HotelItemStatus status in HotelItemStatus.values){
      if(status.getNum() == num){
        return status;
      }
    }
    return null;
  }
}

class SimpleHotel implements SimpleMapPoi{
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
  int? stars;
  @override
  double? score;
  @override
  double? latitude;
  @override
  double? longitude;

  @override
  String? cover;
  @override
  int? price;

  SimpleHotel();
  SimpleHotel.fromJson(dynamic json){
    source = json['source'];
    outerId = json['outerId'];
    id = json['id'];

    name = json['name'];
    city = json['city'];
    address = json['address'];
    stars = json['stars'];
    score = json['score'];
    latitude = json['latitude'];
    longitude = json['longitude'];

    cover = json['cover'];
    price = json['price'];
  }

  SimpleHotel.fromFreego(dynamic json){
    source = 'freego';
    id = json['id'];

    name = json['name'];
    city = json['city'];
    address = json['address'];
    stars = json['stars'];
    
    score = json['score'];
    latitude = json['latitude'];
    longitude = json['longitude'];

    cover = json['cover'];
    price = json['price'];
  }

  SimpleHotel.fromPanhe(dynamic json){
    source = 'panhe';
    outerId = json['hotelId'];

    name = json['hotelName'];
    city = json['cityName'];
    address = json['address'];
    stars = json['stars'] + 1;
    score = json['avgScore'];
    latitude = json['googleLat'];
    longitude = json['googleLon'];

    cover = json['mainImage'];
    price = json['startingPrice'];
  }

  SimpleHotel.fromGaode(dynamic json){
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

enum HotelPayType{
  advance, // 预付
  payg // 现付
}

extension PayTypeExt on HotelPayType{
  int getNum(){
    switch(this){
      case HotelPayType.advance:
        return 0;
      case HotelPayType.payg:
        return 1;
    }
  }
  static HotelPayType? getType(int num){
    for(HotelPayType type in HotelPayType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

enum ConfirmType{
  instant,
  notInstant
}

extension ConfirmTypeExt on ConfirmType{
  int getNum(){
    switch(this){
      case ConfirmType.notInstant:
        return 0;
      case ConfirmType.instant:
        return 1;
    }
  }
  static ConfirmType? getType(int num){
    for(ConfirmType type in ConfirmType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

enum CancelRuleType{
  unable,
  inTime,
  charged
}

extension CancelRuleTypeExt on CancelRuleType{
  int getNum(){
    switch(this){
      case CancelRuleType.unable:
        return 1;
      case CancelRuleType.inTime:
        return 2;
      case CancelRuleType.charged:
        return 3;
    }
  }
  static CancelRuleType? getType(int num){
    for(CancelRuleType type in CancelRuleType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}
