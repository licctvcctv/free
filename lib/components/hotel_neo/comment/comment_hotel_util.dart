
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/components/hotel_neo/comment/comment_hotel_http.dart';
import 'package:freego_flutter/components/hotel_neo/comment/comment_hotel_model.dart';

class CommentHotelUtil{

  CommentHotelUtil._internal();
  static final CommentHotelUtil _instance = CommentHotelUtil._internal();
  factory CommentHotelUtil(){
    return _instance;
  }

  List<AfterPostCommentHotelHandler> handlerList = [];

  bool addHandler(AfterPostCommentHotelHandler handler){
    if(handlerList.contains(handler)){
      return false;
    }
    handlerList.add(handler);
    return true;
  }

  bool removeHandler(AfterPostCommentHotelHandler handler){
    return handlerList.remove(handler);
  }

  Future<Comment?> post(Comment comment, CommentHotelRaw hotelRaw) async{
    Comment? result = await CommentHotelHttp().post(comment: comment, raw: hotelRaw);
    if(result == null){
      return null;
    }
    for(AfterPostCommentHotelHandler handler in handlerList){
      handler.handle(result);
    }
    return result;
  }
}

abstract class AfterPostCommentHotelHandler{

  void handle(Comment comment);
}
