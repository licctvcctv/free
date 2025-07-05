
import 'package:freego_flutter/model/comment.dart';

class HotelComment implements IComment{
  late Comment comment;
  CommentHotel? commentHotel;

  HotelComment(this.comment);

  HotelComment.fromJson(dynamic json){
    dynamic commentJson = json['comment'];
    comment = Comment.fromJson(commentJson);
    dynamic commentHotelJson = json['commentHotel'];
    commentHotel = CommentHotel.fromJson(commentHotelJson);
  }

  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['comment'] = comment.toJson();
    map['commentHotel'] = commentHotel?.toJson();
    return map;
  }

  @override
  Comment myComment() {
    return comment;
  }
}

class CommentHotel{
  late int commentId;
  int? cleanScore;
  int? positionScore;
  int? serviceScore;
  int? facilityScore;
  CommentHotel(this.commentId);
  CommentHotel.fromJson(dynamic json){
    commentId = json['commentId'];
    cleanScore = json['cleanScore'];
    positionScore = json['positionScore'];
    serviceScore = json['serviceScore'];
    facilityScore = json['facilityScore'];
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['commentId'] = commentId;
    map['cleanScore'] = cleanScore;
    map['positionScore'] = positionScore;
    map['serviceScore'] = serviceScore;
    map['facilityScore'] = facilityScore;
    return map;
  }
}
