
import 'package:freego_flutter/model/behavior_mixin.dart';

class Comment with LikeableMixin{

  int? id;
  int? userId;
  String? content;
  String? pics;
  String? tags;
  int? typeId;
  int? productId;
  int? status;
  int? stars;
  DateTime? createTime;
  DateTime? updateTime;
  int? subNum;
  int? likeNum;

  String? authorName;
  String? authorHead;

  List<CommentSub>? replys;
  int? lastSubId; // 用于同一个对象在不同handler中避免重复调用

  Comment();
  Comment.fromJson(dynamic json){
    id = json['id'];
    userId = json['userId'];
    content = json['content'];
    pics = json['pics'];
    tags = json['tags'];
    typeId = json['typeId'];
    productId = json['productId'];
    status = json['status'];
    stars = json['stars'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] is String){
      updateTime = DateTime.tryParse(json['updateTime']);
    }
    subNum = json['subNum'];
    likeNum = json['likeNum'];
    authorName = json['authorName'];
    authorHead = json['authorHead'];

    if(json['replys'] != null){
      replys ??= [];
      for(dynamic item in json['replys']){
        replys!.add(CommentSub.fromJson(item));
      }
    }

    likeableByJson(json);
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['userId'] = userId;
    map['content'] = content;
    map['pics'] = pics;
    map['tags'] = tags;
    map['typeId'] = typeId;
    map['productId'] = productId;
    map['status'] = status;
    map['stars'] = stars;
    return map;
  }
}

class CommentSub with LikeableMixin{
  int? id;
  int? commentId;
  int? userId;
  String? content;
  DateTime? createTime;
  int? replyId;
  int? likeNum;
  int? status;

  String? authorName;
  String? authorHead;

  CommentSub();
  CommentSub.fromJson(dynamic json){
    id = json['id'];
    commentId = json['commentId'];
    userId = json['userId'];
    content = json['content'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
    replyId = json['replyId'];
    likeNum = json['likeNum'];
    status = json['status'];

    authorName = json['authorName'];
    authorHead = json['authorHead'];

    likeableByJson(json);
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['commentId'] = commentId;
    map['userId'] = userId;
    map['content'] = content;
    map['replyId'] = replyId;
    return map;
  }
}

class CommentTag{
  int? id;
  int? productId;
  int? productType;
  String? tagName;
  int? count;

  CommentTag();
  CommentTag.fromJson(dynamic json){
    id = json['id'];
    productId = json['productId'];
    productType = json['productType'];
    tagName = json['tagName'];
    count = json['count'];
  }
}
