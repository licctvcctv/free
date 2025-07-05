
import 'package:freego_flutter/model/behavior_mixin.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:intl/intl.dart';

abstract class IComment{
  Comment myComment();
}

class Comment with UserMixin, LikeableMixin implements IComment{
  int id;
  int? userId;
  String? content;
  String? pics;
  int? stars;
  int? typeId;
  int? productId;
  int? status;
  DateTime? createTime;
  int? subNum;
  int? likeNum;
  List<CommentSub>? replys;
  Comment(this.id);
  Comment.fromJson(dynamic json) : id = json['id']{
    userId = json['userId'];
    content = json['content'];
    pics = json['pics'];
    stars = json['stars'];
    typeId = json['typeId'];
    productId = json['productId'];
    status = json['status'];
    createTime = DateTime.tryParse(json['createTime']);
    subNum = json['subNum'];
    likeNum = json['likeNum'];
    replys = [];
    if(json['replys'] != null){
      for(dynamic item in json['replys']){
        replys!.add(CommentSub.fromJson(item));
      }
    }
    userName = json['userName'];
    userHead = json['userHead'];
    likeableByJson(json);
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = <String, Object?>{};
    map['id'] = id;
    map['userId'] = userId;
    map['content'] = content;
    map['pics'] = pics;
    map['stars'] = stars;
    map['typeId'] = typeId;
    map['productId'] = productId;
    map['status'] = status;
    if(createTime != null){
      map['createTime'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(createTime!);
    }
    map['subNum'] = subNum;
    return map;
  }
  @override
  Comment myComment(){
    return this;
  }
}

class CommentSub with UserMixin, LikeableMixin{
  int id;
  int? commentId;
  int? userId;
  String? content;
  DateTime? createTime;
  int? replyId;
  int? likeNum;
  CommentSub(this.id);
  CommentSub.fromJson(dynamic json) : id = json['id']{
    commentId = json['commentId'];
    userId = json['userId'];
    content = json['content'];
    createTime = DateTime.tryParse(json['createTime']);
    replyId = json['replyId'];
    userName = json['userName'];
    userHead = json['userHead'];
    likeNum = json['likeNum'];
    likeableByJson(json);
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['commentId'] = commentId;
    map['userId'] = userId;
    map['content'] = content;
    if(createTime != null){
      map['createTime'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(createTime!);
    }
    map['replyId'] = replyId;
    return map;
  }
}
