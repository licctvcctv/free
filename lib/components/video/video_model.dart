
import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';

class VideoModel with StatisticMixin, BehaviorMixin{
  int? id;
  String? name;
  String? path;
  String? pic;
  String? keywords;
  int? userId;
  String? description;
  int? linkProductType;
  int? linkProductId;
  String? city;
  String? address;
  double? lng;
  double? lat;
  String? authorName;
  String? authorHead;
  int? showType;
  int? status;
  DateTime? createTime;
  DateTime? updateTime;
    VideoModel({
    this.id,
    this.name,
    this.path,
    this.pic,
    this.keywords,
    this.userId,
    this.description,
    this.linkProductType,
    this.linkProductId,
    this.city,
    this.address,
    this.lng,
    this.lat,
    this.authorName,
    this.authorHead,
    this.showType,
    this.status,
    this.createTime,
    this.updateTime,
  });
  VideoModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    path = json['path'];
    pic = json['pic'];
    keywords = json['keywords'];
    userId = json['userId'];
    description = json['description'];
    linkProductType = json['linkProductType'];
    linkProductId = json['linkProductId'];
    city = json['city'];
    address = json['address'];
    lng = json['lng'];
    lat = json['lat'];
    authorName = json['authorName'];
    authorHead = json['authorHead'];
    showType = json['showType'];
    status = json['status'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] is String){
      updateTime = DateTime.tryParse(json['updateTime']);
    }
    statisticByJson(json);
    behaviorByJson(json);
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['name'] = name;
    map['path'] = path;
    map['pic'] = pic;
    map['keywords'] = keywords;
    map['userId'] = userId;
    map['description'] = description;
    map['linkProductType'] = linkProductType;
    map['linkProductId'] = linkProductId;
    map['city'] = city;
    map['address'] = address;
    map['lng'] = lng;
    map['lat'] = lat;
    map['showType'] = showType;
    return map;
  }

}

enum VideoStatus{
  verifying,
  verified,
  rejected
}

extension VideoStatusExt on VideoStatus{
  int getNum(){
    switch(this){
      case VideoStatus.verifying:
        return 0;
      case VideoStatus.verified:
        return 1;
      case VideoStatus.rejected:
        return 2;
    }
  }
  String getText(){
    switch(this){
      case VideoStatus.verifying:
        return '审核中';
      case VideoStatus.verified:
        return '审核通过';
      case VideoStatus.rejected:
        return '审核未通过';
    }
  }
  static VideoStatus? getStatus(int num){
    for(VideoStatus status in VideoStatus.values){
      if(status.getNum() == num){
        return status;
      }
    }
    return null;
  }
}

enum ShowType{
  myself,
  friends,
  public
}

extension ShowTypeExt on ShowType{
  int getNum(){
    switch(this){
      case ShowType.myself:
        return 0;
      case ShowType.friends:
        return 1;
      case ShowType.public:
        return 2;
    }
  }
  static ShowType? getType(int num){
    for(ShowType type in ShowType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}
