
import 'package:freego_flutter/http/http_comment.dart';
import 'package:freego_flutter/http/http_comment_hotel.dart';
import 'package:freego_flutter/model/comment.dart';
import 'package:freego_flutter/model/comment_hotel.dart';

class CommentUtil{

  static final List<AfterPostCommentHandler> _afterPostCommentHandlerList = [];

  static bool addAfterPostCommentHandler(AfterPostCommentHandler handler){
    if(_afterPostCommentHandlerList.contains(handler)){
      return false;
    }
    _afterPostCommentHandlerList.add(handler);
    return true;
  }

  static bool removeAfterPostCommentHandler(AfterPostCommentHandler handler){
    return _afterPostCommentHandlerList.remove(handler);
  }

  static Future<Comment?> postComment(Comment comment) async{
    Comment? result = await HttpComment.create(comment);
    if(result != null){
      for(AfterPostCommentHandler handler in _afterPostCommentHandlerList){
        handler.handle(result);
      }
    }
    return result;
  }

  static Future<HotelComment?> postHotelComment(HotelComment hotelComment) async{
    HotelComment? result = await HttpCommentHotel.postComment(hotelComment);
    if(result != null){
      for(AfterPostCommentHandler handler in _afterPostCommentHandlerList){
        handler.handle(result);
      }
    }
    return result;
  }

}

abstract class AfterPostCommentHandler{

  void handle(IComment comment);
}
