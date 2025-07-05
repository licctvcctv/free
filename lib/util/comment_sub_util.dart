
import 'package:freego_flutter/http/http_comment_sub.dart';
import 'package:freego_flutter/model/comment.dart';

class CommentSubUtil{

  static final List<AfterPostCommentSubHandler> _handlerList = [];

  static bool addAfterPostCommentSubHandler(AfterPostCommentSubHandler handler){
    if(_handlerList.contains(handler)){
      return false;
    }
    _handlerList.add(handler);
    return true;
  }

  static bool removeAfterPostCommentSubHandler(AfterPostCommentSubHandler handler){
    return _handlerList.remove(handler);
  }

  static Future<CommentSub?> postCommentSub(CommentSub commentSub) async{
    CommentSub? result = await HttpCommentSub.create(commentSub);
    if(result != null){
      for(AfterPostCommentSubHandler handler in _handlerList){
        handler.handle(result);
      }
    }
    return result;
  }

  static CommentSub createCommentSub({required String content, required int commentId, int? replyId}){
    CommentSub commentSub = CommentSub(0);
    commentSub.content = content;
    commentSub.commentId = commentId;
    commentSub.replyId = replyId;
    return commentSub;
  }
}

abstract class AfterPostCommentSubHandler{

  void handle(CommentSub commentSub);
}
