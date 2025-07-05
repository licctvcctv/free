

import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/statistic_mixin.dart';

class CircleArticleModel with StatisticMixin, BehaviorMixin{
  late int cid;
  int? userId;
  String? pics;
  String? title;
  String? content;
  String? tags;
  String? location;
  double? lng;
  double? lat;
  int status=0;
  List<String> picList = [];
  List<String> tagList=[];

  CircleArticleModel(this.cid);
  CircleArticleModel.fromJson(dynamic json) {
    cid = json['cid'];
    pics = json['pics'];
    title = json['title'];
    content = json['content'];
    tags = json['tags'];
    location  = json['location'];
    lng = json['lng'];
    lat = json['lat'];
    userId = json['userId'];
    picList = pics!=null?pics!.split(','):picList;
    tagList = tags!=null?tags!.split(","):[];

    statisticByJson(json);
    behaviorByJson(json);
  }
}
