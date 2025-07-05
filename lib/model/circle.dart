
import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/date_time_util.dart';

class Circle with StatisticMixin{
  late int id;
  int? userId;
  int? type;
  String? brief;
  String? pic;
  String? location;
  double? lng;
  double? lat;
  int? status;
  DateTime? createTime;
  DateTime? updateTime;
  Circle(this.id);
  Circle.fromJson(dynamic json){

    id = json['id'];
    userId = json['userId'];
    type = json['type'];
    pic = json['pic'];
    brief = json['brief'];
    location = json['location'];
    lng = json['lng'];
    lat = json['lat'];
    status = json['status'];
    createTime = DateTime.parse(json['createTime']);
    updateTime = DateTime.parse(json['updateTime']);
    statisticByJson(json);
  }

  Map toJson(){
    Map map = {};
    map['id'] = id;
    map['userId'] = userId;
    map['type'] = type;
    map['brief'] = brief;
    map['pic'] = pic;
    map['location'] = location;
    map['lng'] = lng;
    map['lat'] = lat;
    map['status'] = status;
    map['createTime'] = createTime != null ? DateTimeUtil.toFormat(createTime!, 'yyyy-MM-dd') : null;
    return map;
  }

  static const int STATUS_DRAFT = 0;
  static const int STATUS_PUBLISHED = 1;

  static const int TYPE_ACTIVITY = 1;
  static const int TYPE_ARTICLE = 2;
  static const int TYPE_QUESTION = 3;
  static const int TYPE_SHOP = 4;
}

class CircleActivity{
  late int cid;
  String? name;
  String? description;
  String? pics;
  int? guideId;
  String? startPoint;
  DateTime? startTime;
  int? peopleNum;
  int? expectNumMin;
  int? expectNumMax;
  int? chatGroupId;
  int? activityStatus;
  CircleActivity(this.cid);
  Map toJson(){
    Map map = {};
    map['cid'] = cid;
    map['name'] = name;
    map['description'] = description;
    map['pics'] = pics;
    map['guideId'] = guideId;
    map['startPoint'] = startPoint;
    map['startTime'] = startTime != null ? DateTimeUtil.toFormat(startTime!, 'yyyy-MM-dd') : null;
    map['peopleNum'] = peopleNum;
    map['expectNumMin'] = expectNumMin;
    map['expectNumMax'] = expectNumMax;
    map['chatGroupId'] = chatGroupId;
    map['activityStatus'] = activityStatus;
    return map;
  }
}

class CircleActivityExt extends Circle with UserMixin, BehaviorMixin{
  late int cid;
  String? name;
  String? description;
  String? pics;
  int? guideId;
  String? startPoint;
  DateTime? startTime;
  int? peopleNum;
  int? expectNumMin;
  int? expectNumMax;
  int? chatGroupId;
  int? activityStatus;
  String? guideName;
  List<String>? spots;
  int? applyStatus;
  CircleActivityExt(super.id);
  CircleActivityExt.fromJson(dynamic json):super(json['circle']['id']){
    dynamic circle = json['circle'];
    id = circle['id'];
    userId = circle['userId'];
    type = circle['type'];
    pic = circle['pic'];
    brief = circle['brief'];
    location = circle['location'];
    lng = circle['lng'];
    lat = circle['lat'];
    status = circle['status'];
    createTime = DateTime.parse(circle['createTime']);
    dynamic activity = json['activity'];
    cid = activity['cid'];
    name = activity['name'];
    pics = activity['pics'];
    description = activity['description'];
    guideId = activity['guideId'];
    startPoint = activity['startPoint'];
    startTime = DateTime.parse(activity['startTime']);
    peopleNum = activity['peopleNum'];
    expectNumMax = activity['expectNumMax'];
    expectNumMin = activity['expectNumMin'];
    chatGroupId = activity['chatGroupId'];
    activityStatus = activity['activityStatus'];
    guideName = json['guideName'];
    spots = [];
    for(String item in json['spots']){
      spots!.add(item);
    }
    applyStatus = json['applyStatus'];

    userName = json['userName'];
    userHead = json['userHead'];

    statisticByJson(circle);
    behaviorByJson(json);
  }

  @override
  Map toJson(){
    Map map = {};
    map['id'] = id;
    map['userId'] = userId;
    map['type'] = type;
    map['brief'] = brief;
    map['pic'] = pic;
    map['location'] = location;
    map['lng'] = lng;
    map['lat'] = lat;
    map['status'] = status;
    map['createTime'] = createTime != null ? DateTimeUtil.toFormat(createTime!, 'yyyy-MM-dd') : null;
    map['cid'] = cid;
    map['name'] = name;
    map['pics'] = pics;
    map['description'] = description;
    map['guideId'] = guideId;
    map['startPoint'] = startPoint;
    map['startTime'] = startTime != null ? DateTimeUtil.toFormat(startTime!, 'yyyy-MM-dd') : null;
    map['peopleNum'] = peopleNum;
    map['expectNumMax'] = expectNumMax;
    map['expectNumMin'] = expectNumMin;
    map['chatGroupId'] = chatGroupId;
    map['activityStatus'] = activityStatus;
    return map;
  }

  static const int ACTIVITY_STATUS_EMPTY = 0; // 创建中状态
  static const int ACTIVITY_STATUS_ON = 1; // 招募中状态
  static const int ACTIVITY_STATUS_END = 2; // 已结束状态
}

class CircleActivityApply with UserMixin{
  late int id;
  int? circleId;
  int? userId;
  String? description;
  DateTime? createTime;
  int? status;

  CircleActivityApply(this.id);
  CircleActivityApply.fromJson(dynamic json){
    id = json['id'];
    circleId = json['circleId'];
    userId = json['userId'];
    description = json['description'];
    createTime = DateTime.parse(json['createTime']);
    status = json['status'];
    userName = json['userName'];
    userHead = json['userHead'];
  }

  static const int STATUS_EMPTY = 0; // 未报名状态
  static const int STATUS_WAITING = 1; // 报名处理中
  static const int STATUS_SUCCESS = 2; // 报名成功
}

class CircleArticle extends Circle with UserMixin, BehaviorMixin{
  late int cid;
  String? pics;
  String? title;
  String? content;
  String? tags;
  CircleArticle(super.id);
  CircleArticle.fromJson(dynamic json):super(json['circle']['id']){
    dynamic circle = json['circle'];
    id = circle['id'];
    userId = circle['userId'];
    type = circle['type'];
    pic = circle['pic'];
    brief = circle['brief'];
    location = circle['location'];
    lng = circle['lng'];
    lat = circle['lat'];
    status = circle['status'];
    createTime = DateTime.parse(circle['createTime']);
    dynamic article = json['article'];
    cid = article['cid'];
    pics = article['pics'];
    title = article['title'];
    content = article['content'];
    tags = article['tags'];
    userName = json['userName'];
    userHead = json['userHead'];

    statisticByJson(circle);
    behaviorByJson(json);
  }
}

class CircleQuestion extends Circle with UserMixin, BehaviorMixin{
  late int cid;
  String? title;
  String? content;
  String? pics;
  String? tags;
  int? isAnonymous;
  CircleQuestion(super.id);
  CircleQuestion.fromJson(dynamic json):super(json['circle']['id']){
    dynamic circle = json['circle'];
    id = circle['id'];
    userId = circle['userId'];
    type = circle['type'];
    pic = circle['pic'];
    brief = circle['brief'];
    location = circle['location'];
    lng = circle['lng'];
    lat = circle['lat'];
    status = circle['status'];
    createTime = DateTime.parse(circle['createTime']);
    dynamic question = json['question'];
    cid = question['cid'];
    title = question['title'];
    content = question['content'];
    pics = question['pics'];
    tags = question['tags'];
    isAnonymous = question['isAnonymous'];
    userName = json['userName'];
    userHead = json['userHead'];

    statisticByJson(circle);
    behaviorByJson(json);
  }
}

class CircleShop extends Circle with UserMixin, BehaviorMixin{
  late int cid;
  String? name;
  String? pics;
  String? phone;
  String? openCloseTime;
  String? description;
  CircleShop(super.id);
  CircleShop.fromJson(dynamic json):super(json['circle']['id']){
    dynamic circle = json['circle'];
    id = circle['id'];
    userId = circle['userId'];
    type = circle['type'];
    pic = circle['pic'];
    brief = circle['brief'];
    location = circle['location'];
    lng = circle['lng'];
    lat = circle['lat'];
    status = circle['status'];
    createTime = DateTime.parse(circle['createTime']);
    dynamic shop = json['shop'];
    cid = shop['cid'];
    name = shop['name'];
    pics = shop['pics'];
    phone = shop['phone'];
    openCloseTime = shop['openCloseTime'];
    description = shop['description'];
    userName = json['userName'];
    userHead = json['userHead'];

    statisticByJson(circle);
    behaviorByJson(json);
  }
}

class CircleQuestionAnswer with UserMixin{
  late int id;
  int? userId;
  int? questionId;
  String? content;
  String? pics;
  DateTime? createTime;
  int? likeNum;
  CircleQuestionAnswer.fromJson(dynamic json){
    id = json['id'];
    userId = json['userId'];
    questionId = json['questionId'];
    content = json['content'];
    pics = json['pics'];
    createTime = DateTime.parse(json['createTime']);
    userName = json['userName'];
    userHead = json['userHead'];
    likeNum = json['likeNum'];
  }

}
