
import 'package:freego_flutter/components/trip/trip_common.dart';
import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';
import 'package:freego_flutter/util/date_time_util.dart';

abstract class Circle with StatisticMixin, BehaviorMixin{

  int? id;
  int? userId;
  int? type;
  String? name;
  String? keywords;
  String? pic;
  String? city;
  String? location;
  double? lat;
  double? lng;
  int? status;
  DateTime? createTime;
  DateTime? updateTime;

  String? authorName;
  String? authorHead;
  
  Circle();
  Circle.fromJson(dynamic json){
    id = json['id'];
    userId = json['userId'];
    type = json['type'];
    name = json['name'];
    keywords = json['keywords'];
    pic = json['pic'];
    city = json['city'];
    location = json['location'];
    lat = json['lat'];
    lng = json['lng'];
    status = json['status'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] is String){
      updateTime = DateTime.tryParse(json['updateTime']);
    }

    statisticByJson(json);
    behaviorByJson(json);

    authorName = json['authorName'];
    authorHead = json['authorHead'];
  }

  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['userId'] = userId;
    map['type'] = type;
    map['name'] = name;
    map['keywords'] = keywords;
    map['pic'] = pic;
    map['city'] = city;
    map['location'] = location;
    map['lat'] = lat;
    map['lng'] = lng;
    map['status'] = status;
    return map;
  }
  
}

enum CircleType{
  activity,
  article,
  question,
  shop
}

extension CircleTypeExt on CircleType{
  int getNum(){
    switch(this){
      case CircleType.activity:
        return 1;
      case CircleType.article:
        return 2;
      case CircleType.question:
        return 3;
      case CircleType.shop:
        return 4;
    }
  }
  static CircleType? getType(int num){
    for(CircleType type in CircleType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

class CircleActivity extends Circle{

  String? description;
  String? pics;
  int? tripId;
  String? assemblingSpot;
  double? assemblingLat;
  double? assemblingLng;
  DateTime? startTime;
  int? peopleNum;
  int? expectNumMax;
  int? expectNumMin;
  int? chatGroupId;
  int? activityStatus;

  TripVo? trip;

  CircleActivity.fromJson(dynamic json) : super.fromJson(json){
    description = json['description'];
    pics = json['pics'];
    tripId = json['tripId'];
    assemblingSpot = json['assemblingSpot'];
    assemblingLat = json['assemblingLat'];
    assemblingLng = json['assemblingLng'];
    if(json['startTime'] is String){
      startTime = DateTime.tryParse(json['startTime']);
    }
    peopleNum = json['peopleNum'];
    expectNumMax = json['expectNumMax'];
    expectNumMin = json['expectNumMin'];
    chatGroupId = json['chatGroupId'];
    activityStatus = json['activityStatus'];
    if(json['trip'] != null){
      trip = TripVo.fromJson(json['trip']);
    }
  }

  @override
  Map<String, Object?> toJson(){
    Map<String, Object?> map = super.toJson();
    map['description'] = description;
    map['pics'] = pics;
    map['tripId'] = tripId;
    map['assemblingSpot'] = assemblingSpot;
    map['assemblingLat'] = assemblingLat;
    map['assemblingLng'] = assemblingLng;
    if(startTime != null){
      map['startTime'] = DateTimeUtil.toFormat(startTime!, 'yyyy-MM-dd HH:mm');
    }
    map['peopleNum'] = peopleNum;
    map['expectNumMax'] = expectNumMax;
    map['expectNumMin'] = expectNumMin;
    map['chatGroupId'] = chatGroupId;
    map['activityStatus'] = activityStatus;
    return map;
  }
}

enum CircleActivityStatus{
  preparing,
  recruiting,
  completed;
}

extension CircleActivityStatusExt on CircleActivityStatus{
  int getNum(){
    switch(this){
      case CircleActivityStatus.preparing:
        return 0;
      case CircleActivityStatus.recruiting:
        return 1;
      case CircleActivityStatus.completed:
        return 2;
    }
  }
  static CircleActivityStatus? getStatus(int num){
    for(CircleActivityStatus status in CircleActivityStatus.values){
      if(status.getNum() == num){
        return status;
      }
    }
    return null;
  }
}

enum CircleActivityApplyStatus{
  empty,
  waiting,
  success,
  rejected
}

extension CircleActivityApplyStatusExt on CircleActivityApplyStatus{
  int getNum(){
    switch(this){
      case CircleActivityApplyStatus.empty:
        return 0;
      case CircleActivityApplyStatus.waiting:
        return 1;
      case CircleActivityApplyStatus.success:
        return 2;
      case CircleActivityApplyStatus.rejected:
        return 3;
    }
  }
  static CircleActivityApplyStatus? getStatus(int num){
    for(CircleActivityApplyStatus status in CircleActivityApplyStatus.values){
      if(status.getNum() == num){
        return status;
      }
    }
    return null;
  }
}

class CircleArticle extends Circle{

  String? title;
  String? pics;
  String? content;

  CircleArticle.fromJson(dynamic json) : super.fromJson(json){
    title = json['title'];
    pics = json['pics'];
    content = json['content'];
  }


  @override
  Map<String, Object?> toJson(){
    Map<String, Object?> map = super.toJson();
    map['title'] = title;
    map['pics'] = pics;
    map['content'] = content;
    return map;
  }
}

class CircleQuestion extends Circle{

  String? title;
  String? content;
  String? pics;
  bool? isAnonymous;
  int? answerNum;

  CircleQuestion.fromJson(dynamic json) : super.fromJson(json){
    title = json['title'];
    content = json['content'];
    pics = json['pics'];
    isAnonymous = json['isAnonymous'];
    answerNum = json['answerNum'];
  }

  @override
  Map<String, Object?> toJson(){
    Map<String, Object?> map = super.toJson();
    map['title'] = title;
    map['content'] = content;
    map['pics'] = pics;
    map['isAnonymous'] = isAnonymous;
    map['answerNum'] = answerNum;
    return map;
  }
}

class CircleShop extends Circle{

  String? shopName;
  String? address;
  String? pics;
  String? content;
  String? phone;
  String? openTime;
  String? closeTime;
  String? openDays;

  CircleShop.fromJson(dynamic json) : super.fromJson(json){
    shopName = json['shopName'];
    address = json['address'];
    pics = json['pics'];
    content = json['content'];
    phone = json['phone'];
    openTime = json['openTime'];
    closeTime = json['closeTime'];
    openDays = json['openDays'];
  }

  @override
  Map<String, Object?> toJson(){
    Map<String, Object?> map = super.toJson();
    map['shopName'] = shopName;
    map['address'] = address;
    map['pics'] = pics;
    map['content'] = content;
    map['phone'] = phone;
    map['openTime'] = openTime;
    map['closeTime'] = closeTime;
    map['openDays'] = openDays;
    return map;
  }
}