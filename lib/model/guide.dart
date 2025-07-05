
import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:video_player/video_player.dart';

class GuideModel with UserMixin, StatisticMixin, BehaviorMixin{
  late int id;
  String? name;
  String? keywords;
  String? pic;
  String? description;
  int? userId;
  String? startPoint;
  String? endPoint;
  DateTime? startDate;
  DateTime? endDate;
  int? trafficType;
  int? hotelType;
  int? strengthType;
  int? defaultReward;
  DateTime? createTime;
  DateTime? updateTime;
  List<GuideDayModel>? dayList;
  GuideModel(this.id);
  GuideModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    keywords = json['keywords'];
    pic = json['pic'];
    description = json['description'];
    userId = json['userId'];
    startPoint = json['startPoint'];
    endPoint = json['endPoint'];
    if(json['startDate'] != null){
      startDate = DateTime.tryParse(json['startDate']);
    }
    if(json['endDate'] != null){
      endDate = DateTime.tryParse(json['endDate']);
    }
    trafficType = json['trafficType'];
    hotelType = json['hotelType'];
    strengthType = json['strengthType'];
    defaultReward = json['defaultReward'];
    if(json['createTime'] != null){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] != null){
      updateTime = DateTime.tryParse(json['updateTime']);
    }
    if(json['dayList'] != null){
      dayList = [];
      for(dynamic item in json['dayList']){
        dayList!.add(GuideDayModel.fromJson(item));
      }
    }
    userName = json['userName'];
    userHead = json['userHead'];
    score = json['score'];
    showNum = json['showNum'];
    commentNum = json['commentNum'];
    likeNum = json['likeNum'];
    favoriteNum = json['favoriteNum'];
    shareNum = json['shareNum'];
    isLiked = json['isLiked'];
    isFavorited = json['isFavorited'];
  }
}

class GuideDayModel{
  late int id;
  int? guideId;
  int? dayNum;
  String? description;
  List<GuideDayPointModel>? children;
  GuideDayModel.fromJson(dynamic json){
    id = json['id'];
    guideId = json['guideId'];
    dayNum = json['dayNum'];
    description = json['description'];
    children = [];
    for(dynamic item in json['children']){
      children!.add(GuideDayPointModel.fromJson(item));
    }
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['guideId'] = guideId;
    map['dayNum'] = dayNum;
    map['description'] = description;
    if(children != null){
      List<dynamic> list = [];
      for(GuideDayPointModel point in children!){
        list.add(point.toJson());
      }
      map['children'] = list;
    }
    return map;
  }
}

class GuideDayPointModel{
  late int id;
  int? guideId;
  int? dayNum;
  String? startTime;
  String? endTime;
  int? pointType;
  String? pointName;
  double? lng;
  double? lat;
  String? pics;
  String? video;
  String? description; 
  VideoPlayerController? videoController;
  GuideDayPointModel(this.id);
  GuideDayPointModel.fromJson(dynamic json) {
    id = json['id'];
    guideId = json['guideId'];
    dayNum = json['dayNum'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    pointType = json['pointType'];
    pointName = json['pointName'];
    lng = json['lng'];
    lat = json['lat'];
    pics = json['pics'];
    video = json['video'];
    description = json['description'];
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['guideId'] = guideId;
    map['dayNum'] = dayNum;
    map['startTime'] = startTime;
    map['endTime'] = endTime;
    map['pointType'] = pointType;
    map['pointName'] = pointName;
    map['lng'] = lng;
    map['lat'] = lat;
    map['pics'] = pics;
    map['video'] = video;
    map['description'] = description;
    return map;
  }
}
