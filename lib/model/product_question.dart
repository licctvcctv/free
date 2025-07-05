
import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/user.dart';

class ProductQuestion with UserMixin{
  late int id;
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
  List<ProductQuestionAnswer>? answerList;
  ProductQuestion(this.id);
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
    isAnonymous = json['isAnomymous'];
    createTime = DateTime.parse(json['createTime']);
    userName = json['userName'];
    userHead = json['userHead'];
    if(json['answerList'] != null){
      answerList = [];
      for(dynamic item in json['answerList']){
        answerList!.add(ProductQuestionAnswer.fromJson(item));
      }
    }
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = <String, Object?>{};
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
    return map;
  }

}

class ProductQuestionAnswer with UserMixin, LikeableMixin{
  late int id;
  int? questionId;
  int? userId;
  String? content;
  DateTime? createTime;
  int? likeNum;
  ProductQuestionAnswer(this.id);
  ProductQuestionAnswer.fromJson(dynamic json){
    id = json['id'];
    questionId = json['questionId'];
    userId = json['userId'];
    content = json['content'];
    createTime = DateTime.parse(json['createTime']);
    userName = json['userName'];
    userHead = json['userHead'];
    likeNum = json['likeNum'];
    likeableByJson(json);
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = <String, Object?>{};
    map['id'] = id;
    map['questionId'] = questionId;
    map['userId'] = userId;
    map['content'] = content;
    return map;
  }
}
