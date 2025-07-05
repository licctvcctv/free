

import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';

class CircleQuestionModel with StatisticMixin, BehaviorMixin{
  late int cid;
  String? pics;
  String? title;
  String? content;
  int? userId;
  String? tags;
  String? location;
  double? lng;
  double? lat;
  int status=0;
  int isAnonymous = 0;
  List<String> picList = [];
  List<String> tagList=[];

  CircleQuestionModel(this.cid);
  CircleQuestionModel.fromJson(dynamic json) {
    cid = json['cid'];
    pics = json['pics'];
    title = json['title'];
    content = json['content'];
    tags = json['tags'];
    userId = json['userId'];

    location  = json['location'];
    lng = json['lng'];
    lat = json['lat'];
    picList = pics!=null?pics!.split(','):picList;
    tagList = tags!=null?tags!.split(","):[];
    isAnonymous = json['isAnonymous'];

    statisticByJson(json);
    behaviorByJson(json);
  }
}