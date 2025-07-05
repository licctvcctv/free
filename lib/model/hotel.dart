
import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';

class Hotel with StatisticMixin, BehaviorMixin, HotelScoreMixin{
  late int id;
  int? userId;
  String? name;
  String? shortName;
  int? type;
  String? keywords;
  String? province;
  String? city;
  String? district;
  String? address;
  DateTime? openDate;
  int? roomNum;
  int? rank;
  String? pics;
  String? video;
  String? introduction;
  int? orderConfirmHours;
  int? orderBeforeDays;
  bool? isQuickCancel;
  String? entryTime;
  int? minPrice;
  DateTime? minPriceUpdateDate;
  String? leaveTime;
  bool? isChildAllowed;
  String? childPolicy;
  bool? isPetAllowed;
  bool? isForeignerAllowed;
  DateTime? createTime;
  DateTime? updateTime;
  double? lat;
  double? lng;
  List<HotelServiceItem>? hotelServiceItemVoList;
  List<HotelRoomType>? roomTypeVoList;
  List<HotelRoom>? roomList;
  Hotel(this.id);
  Hotel.fromJson(dynamic json){
    id = json['id'];
    userId = json['userId'];
    name = json['name'];
    shortName = json['shortName'];
    type = json['type'];
    keywords = json['keywords'];
    city = json['city'];
    district = json['district'];
    address = json['address'];
    if(json['openDate'] != null){
      openDate = DateTime.tryParse(json['openDate']);
    }
    roomNum = json['roomNum'];
    rank = json['rank'];
    pics = json['pics'];
    video = json['video'];
    introduction = json['introduction'];
    orderConfirmHours = json['orderConfirmHours'];
    orderBeforeDays = json['orderBeforeDays'];
    isQuickCancel = json['isQuickCancel'] != null && json['isQuickCancel'] > 0;
    entryTime = json['entryTime'];
    minPrice = json['minPrice'];
    if(json['minPriceUpdateDate'] != null){
      minPriceUpdateDate = DateTime.tryParse(json['minPriceUpdateDate']);
    }
    leaveTime = json['leaveTime'];
    isChildAllowed = json['isChildAllowed'] != null && json['isChildAllowed'] > 0;
    isForeignerAllowed = json['isForeignerAllowed'] != null && json['isForeignerAllowed'] > 0;
    showNum = json['showNum'];
    if(json['createTime'] != null){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] != null){
      updateTime = DateTime.tryParse(json['updateTime']);
    }
    lat = json['lat'];
    lng = json['lng'];
    if(json['hotelServiceItemVoList'] != null){
      hotelServiceItemVoList = [];
      for(dynamic item in json['hotelServiceItemVoList']){
        hotelServiceItemVoList!.add(HotelServiceItem.fromJson(item));
      }
    }
    if(json['roomTypeVoList'] != null){
      roomTypeVoList = [];
      for(dynamic item in json['roomTypeVoList']){
        roomTypeVoList!.add(HotelRoomType.fromJson(item));
      }
    }
    if(json['roomList'] != null){
      roomList = [];
      for(dynamic item in json['roomList']){
        roomList!.add(HotelRoom.fromJson(item));
      }
    }
    showNum = json['showNum'];
    commentNum = json['commentNum'];
    likeNum = json['likeNum'];
    favoriteNum = json['favoriteNum'];
    shareNum = json['shareNum'];
    score = json['score'];
    isLiked = json['isLiked'];
    isFavorited = json['isFavorited'];

    hotelScoreByJson(json);
  }
}

class HotelRoom{
  late int id;
  int? hotelId;
  int? roomTypeId;
  String? name;
  String? floors;
  double? areaSize;
  int? breakfirstType;
  int? breakfirstPrice;
  String? bed;
  int? peopleLimit;
  int? roomNum;
  int? facWifiHas;
  int? facDryerHas;
  int? facWindowHas;
  int? facTvHas;
  int? facAirCondHas;
  String? pics;
  String? introduction;
  DateTime? createTime;
  DateTime? updateTime;
  HotelRoom(this.id);
  HotelRoom.fromJson(dynamic json){
    id = json['id'];
    hotelId = json['hotelId'];
    roomTypeId = json['roomTypeId'];
    name = json['name'];
    floors = json['floors'];
    areaSize = json['areaSize'];
    breakfirstType = json['breakfirstType'];
    breakfirstPrice = json['breakfirstPrice'];
    bed = json['bed'];
    peopleLimit = json['peopleLimit'];
    roomNum = json['roomNum'];
    facWifiHas = json['facWifiHas'];
    facDryerHas = json['facDryerHas'];
    facWindowHas = json['facWindowHas'];
    facTvHas = json['facTvHas'];
    facAirCondHas = json['facAirCondHas'];
    pics = json['pics'];
    introduction = json['introduction'];
    if(json['createTime'] != null){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] != null){
      updateTime = DateTime.tryParse(json['updateTime']);
    }
  }
}

class HotelRoomType{
  late int id;
  String? name;
  int? userId;
  int? displayOrder;
  List<HotelRoom>? roomList;
  HotelRoomType(this.id);
  HotelRoomType.fromJson(dynamic json){
    id = json['id'];
    name = json['name'];
    userId = json['userId'];
    displayOrder = json['displayOrder'];
    if(json['roomList'] != null){
      roomList = [];
      for(dynamic item in json['roomList']){
        roomList!.add(HotelRoom.fromJson(item));
      }
    }
  }
}

class HotelServiceItem{
  late int id;
  int? hotelId;
  int? hotelServiceTypeId;
  int? chargeType;
  String? description;
  String? name;
  int? pid;
  List<HotelServiceItem>? children;
  HotelServiceItem(this.id);
  HotelServiceItem.fromJson(dynamic json){
    id = json['id'];
    hotelId = json['hotelId'];
    hotelServiceTypeId = json['hotelServiceTypeId'];
    chargeType = json['chargeType'];
    description = json['description'];
    name = json['name'];
    pid = json['pid'];
    children = [];
  }
}

class HotelRoomPrice{
  late int id;
  int? hotelRoomId;
  int? hotelId;
  DateTime? day;
  int? price;
  int? stock;
  HotelRoomPrice(this.id);
  HotelRoomPrice.fromJson(dynamic json){
    id = json['id'];
    hotelRoomId = json['hotelRoomId'];
    hotelId = json['hotelId'];
    if(json['day'] != null){
      day = DateTime.tryParse(json['day']);
    }
    price = json['price'];
    stock = json['stock'];
  }
}
