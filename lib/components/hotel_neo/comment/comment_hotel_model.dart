
import 'package:freego_flutter/components/comment/comment_model.dart';

class CommentHotelRaw{
  int? cid;
  int? cleanScore;
  int? positionScore;
  int? serviceScore;
  int? facilityScore;

  CommentHotelRaw();

  CommentHotelRaw.fromJson(dynamic json){
    cid = json['cid'];
    cleanScore = json['cleanScore'];
    positionScore = json['positionScore'];
    serviceScore = json['serviceScore'];
    facilityScore = json['facilityScore'];
  }
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['cid'] = cid;
    map['cleanScore'] = cleanScore;
    map['positionScore'] = positionScore;
    map['serviceScore'] = serviceScore;
    map['facilityScore'] = facilityScore;
    return map;
  }
}

class CommentHotel extends Comment implements CommentHotelRaw{

  @override
  int? cid;
  @override
  int? cleanScore;
  @override
  int? facilityScore;
  @override
  int? positionScore;
  @override
  int? serviceScore;

  CommentHotel.fromJson(dynamic json) : super.fromJson(json){
    cid = json['cid'];
    cleanScore = json['cleanScore'];
    positionScore = json['positionScore'];
    serviceScore = json['serviceScore'];
    facilityScore = json['facilityScore'];
  }
}
