
import 'package:freego_flutter/model/map_poi.dart';
import 'package:intl/intl.dart';

class TripVo extends Trip{

  TripVo();
  List<TripPoint>? points;
  TripVo.fromJson(dynamic json) : super.fromJson(json){
    if(json['points'] is List){
      points = [];
      for(dynamic item in json['points']){
        points?.add(TripPoint.fromJson(item));
      }
    }
  }
}

class Trip{

  int? id;
  String? cover;
  String? startAddress;
  double? startLatitude;
  double? startLongitude;
  String? endAddress;
  double? endLatitude;
  double? endLongitude;
  DateTime? startDate;
  DateTime? endDate;
  int? travelMode;
  int? accommodateType;
  int? intensityType;
  int? totalNum;
  DateTime? createTime;
  DateTime? modifyTime;

  Trip();
  Trip.fromJson(dynamic json){
    id = json['id'];
    cover = json['cover'];
    startAddress = json['startAddress'];
    startLatitude = json['startLatitude'];
    startLongitude = json['startLongitude'];
    endAddress = json['endAddress'];
    endLatitude = json['endLatitude'];
    endLongitude = json['endLongitude'];
    if(json['startDate'] is String){
      startDate = DateTime.tryParse(json['startDate']);
    }
    if(json['endDate'] is String){
      endDate = DateTime.tryParse(json['endDate']);
    }
    travelMode = json['travelMode'];
    accommodateType = json['accommodateType'];
    intensityType = json['intensityType'];
    totalNum = json['totalNum'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['modifyTime'] is String){
      modifyTime = DateTime.tryParse(json['modifyTime']);
    }
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['cover'] = cover;
    map['startAddress'] = startAddress;
    map['startLatitude'] = startLatitude;
    map['startLongitude'] = startLongitude;
    map['endAddress'] = endAddress;
    map['endLatitude'] = endLatitude;
    map['endLongitude'] = endLongitude;
    if(startDate != null){
      map['startDate'] = DateFormat('yyyy-MM-dd').format(startDate!);
    }
    if(endDate != null){
      map['endDate'] = DateFormat('yyyy-MM-dd').format(endDate!);
    }
    map['travelMode'] = travelMode;
    map['accommodateType'] = accommodateType;
    map['intensityType'] = intensityType;
    map['totalNum'] = totalNum;
    if(createTime != null){
      map['createTime'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(createTime!);
    }
    if(modifyTime != null){
      map['modifyTime'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(modifyTime!);
    }
    return map;
  }
}

class TripPoint{
  int? id;
  String? source;
  String? outerId;
  int? orderNum;
  String? name;
  String? address;
  String? image;
  double? latitude;
  double? longitude;
  int? type;
  int? tripId;
  int? tripDay;
  DateTime? createTime;

  MapPoiModel? mapPoi;

  TripPoint();
  TripPoint.fromJson(dynamic json){
    id = json['id'];
    source = json['source'];
    outerId = json['outerId'];
    orderNum = json['orderNum'];
    name = json['name'];
    address = json['address'];
    image = json['image'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    type = json['type'];
    tripId = json['tripId'];
    tripDay = json['tripDay'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['source'] = source;
    map['outerId'] = outerId;
    map['orderNum'] = orderNum;
    map['name'] = name;
    map['address'] = address;
    map['image'] = image;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['type'] = type;
    map['tripId'] = tripId;
    map['tripDay'] = tripDay;
    if(createTime != null){
      map['createTime'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(createTime!);
    }
    return map;
  }
}

enum TravelMode{
  selfDrive,
  nonSelfDrive
}

extension TravelModeExt on TravelMode{
  int getNum(){
    switch(this){
      case TravelMode.selfDrive:
        return 1;
      case TravelMode.nonSelfDrive:
        return 2;
    }
  }
  static TravelMode? getMode(int num){
    for(TravelMode mode in TravelMode.values){
      if(mode.getNum() == num){
        return mode;
      }
    }
    return null;
  }
}

enum AccommodateType{
  economic,
  confortable,
  luxury
}

extension AccommodateTypeExt on AccommodateType{
  int getNum(){
    switch(this){
      case AccommodateType.economic:
        return 1;
      case AccommodateType.confortable:
        return 2;
      case AccommodateType.luxury:
        return 3;
    }
  }
  static AccommodateType? getType(int num){
    for(AccommodateType type in AccommodateType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

enum IntensityType{
  tight,
  normal,
  casual
}

extension IntensityTypeExt on IntensityType{
  int getNum(){
    switch(this){
      case IntensityType.tight:
        return 1;
      case IntensityType.normal:
        return 2;
      case IntensityType.casual: 
        return 3;
    }
  }
  static IntensityType? getType(int num){
    for(IntensityType type in IntensityType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}
