
import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';

class Guide with StatisticMixin, BehaviorMixin{
  int? id;
  int? userId;
  String? tags;
  String? title;
  String? reason;
  String? cover;
  int? dayNum;
  bool? isDraft;
  DateTime? createTime;
  DateTime? updateTime;
  int? defaultReward;

  List<GuidePoint>? pointList;

  String? authorName;
  String? authorHead;

  Guide();

  Guide.fromJson(dynamic json){
    id = json['id'];
    userId = json['userId'];
    title = json['title'];
    reason = json['reason'];
    cover = json['cover'];
    dayNum = json['dayNum'];
    isDraft = json['isDraft'];

    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] is String){
      updateTime = DateTime.tryParse(json['updateTime']);
    }

    defaultReward = json['defaultReward'];

    statisticByJson(json);
    behaviorByJson(json);

    if(json['pointList'] is List){
      pointList = [];
      for(dynamic item in json['pointList']){
        pointList!.add(GuidePoint.fromJson(item));
      }
    }

    authorName = json['authorName'];
    authorHead = json['authorHead'];
  }

  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['userId'] = userId;
    map['title'] = title;
    map['reason'] = reason;
    map['cover'] = cover;
    map['dayNum'] = dayNum;
    map['isDraft'] = isDraft;
    map['defaultReward'] = defaultReward;
    return map;
  }
}

class GuidePoint{
  int? id;
  int? guideId;
  String? source;
  String? outerId;
  String? name;
  String? address;
  double? latitude;
  double? longitude;
  String? pics;
  int? day;
  int? orderNum;
  int? type;
  String? description;
  DateTime? createTime;
  DateTime? updateTime;

  GuidePoint();

  GuidePoint.fromJson(dynamic json){
    id = json['id'];
    guideId = json['guideId'];
    source = json['source'];
    outerId = json['outerId'];
    name = json['name'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    pics = json['pics'];
    day = json['day'];
    orderNum = json['orderNum'];
    type = json['type'];
    description = json['description'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] is String){
      updateTime = DateTime.tryParse(json['updateTime']);
    }
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['guideId'] = guideId;
    map['source'] = source;
    map['outerId'] = outerId;
    map['name'] = name;
    map['address'] = address;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['pics'] = pics;
    map['day'] = day;
    map['orderNum'] = orderNum;
    map['type'] = type;
    map['description'] = description;
    return map;
  }
}

enum GuidePointType{
  scenic,
  hotel,
  restaurant
}

extension GuidePointTypeExt on GuidePointType{
  int getNum(){
    switch(this){
      case GuidePointType.scenic:
        return 1;
      case GuidePointType.hotel:
        return 2;
      case GuidePointType.restaurant:
        return 3;
    }
  }
  static GuidePointType? getType(int num){
    for(GuidePointType type in GuidePointType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}
