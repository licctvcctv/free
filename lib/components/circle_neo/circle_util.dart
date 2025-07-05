
import 'package:freego_flutter/components/circle_neo/circle_common.dart';

class CircleConverter{

  CircleConverter._internal();
  static final CircleConverter _instance = CircleConverter._internal();
  factory CircleConverter(){
    return _instance;
  } 

  Circle? convert(dynamic json){
    if(json['type'] is! int){
      return null;
    }
    CircleType? type = CircleTypeExt.getType(json['type']);
    if(type == null){
      return null;
    }
    switch(type){
      case CircleType.activity:
        return CircleActivity.fromJson(json);
      case CircleType.article:
        return CircleArticle.fromJson(json);
      case CircleType.question:
        return CircleQuestion.fromJson(json);
      case CircleType.shop:
        return CircleShop.fromJson(json);
    }
  }
}
