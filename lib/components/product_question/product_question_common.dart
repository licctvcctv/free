
import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:intl/intl.dart';

class ProductQuestion{

  int? id;
  int? productId;
  int? productType;
  int? userId;
  String? title;
  String? content;
  int? answerNum;
  String? pics;
  String? tags;
  bool? isAnonymous;
  DateTime? createTime;
  DateTime? updateTime;

  String? userHead;
  String? userName;

  List<ProductQuestionAnswer>? answerList;

  ProductQuestion();

  ProductQuestion.fromJson(dynamic json){
    id = json['id'];
    productId = json['productId'];
    productType = json['productType'];
    userId = json['userId'];
    title = json['title'];
    content = json['content'];
    answerNum = json['answerNum'];
    pics = json['pics'];
    tags = json['tags'];
    isAnonymous = json['isAnonymous'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] is String){
      updateTime = DateTime.tryParse(json['updateTime']);
    }
    
    userHead = json['userHead'];
    userName = json['userName'];

    if(json['answerList'] is List){
      answerList = [];
      for(dynamic item in json['answerList']){
        answerList!.add(ProductQuestionAnswer.fromJson(item));
      }
    }
  }

  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['productId'] = productId;
    map['productType'] = productType;
    map['userId'] = userId;
    map['title'] = title;
    map['content'] = content;
    map['answerNum'] = answerNum;
    map['pics'] = pics;
    map['tags'] = tags;
    map['isAnonymous'] = isAnonymous;
    map['createTime'] = createTime == null ? null : DateFormat('yyyy-MM-dd').format(createTime!);
    map['updateTime'] = updateTime == null ? null : DateFormat('yyyy-MM-dd').format(updateTime!);
    return map;
  }
}

class ProductQuestionAnswer with LikeableMixin{
  int? id;
  int? questionId;
  int? userId;
  String? content;
  int? likeNum;
  bool? isAnonymous;
  DateTime? createTime;

  String? userHead;
  String? userName;
  ProductQuestionAnswer();

  ProductQuestionAnswer.fromJson(dynamic json){
    id = json['id'];
    questionId = json['questionId'];
    userId = json['userId'];
    content = json['content'];
    likeNum = json['likeNum'];
    isAnonymous = json['isAnonymous'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }

    userHead = json['userHead'];
    userName = json['userName'];

    likeableByJson(json);
  }

  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['questionId'] = questionId;
    map['userId'] = userId;
    map['content'] = content;
    map['likeNum'] = likeNum;
    map['isAnonymous'] = isAnonymous;
    map['createTime'] = createTime == null ? null : DateFormat('yyyy-MM-dd').format(createTime!);
    return map;
  }
}
