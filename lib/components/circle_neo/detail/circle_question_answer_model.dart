
import 'package:freego_flutter/model/behavior_mixin.dart';

class CircleQuestionAnswer with LikeableMixin{

  int? id;
  int? userId;
  int? questionId;
  String? content;
  DateTime? createTime;
  int? likeNum;

  String? userName;
  String? userHead;

  CircleQuestionAnswer.fromJson(dynamic json){

    id = json['id'];
    userId = json['userId'];
    questionId = json['questionId'];
    content = json['content'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
    likeNum = json['likeNum'];

    userName = json['userName'];
    userHead = json['userHead'];

    likeableByJson(json);
  }

  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['userId'] = userId;
    map['questionId'] = questionId;
    map['content'] = content;
    return map;
  }
}
