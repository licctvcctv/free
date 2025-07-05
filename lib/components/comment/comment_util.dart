
import 'package:freego_flutter/components/comment/comment_http.dart';
import 'package:freego_flutter/components/comment/comment_model.dart';

class CommentUtil{

  CommentUtil._inernal();
  static final CommentUtil _instance = CommentUtil._inernal();
  factory CommentUtil(){
    return _instance;
  }

  List<AfterPostCommentHandler> handlerList = [];
  bool addHandler(AfterPostCommentHandler handler){
    if(handlerList.contains(handler)){
      return false;
    }
    handlerList.add(handler);
    return true;
  }
  bool removeHandler(AfterPostCommentHandler handler){
    return handlerList.remove(handler);
  }

  Future<Comment?> postComment(Comment comment) async{
    Comment? result = await CommentHttp().postComment(comment);
    if(result == null){
      return null;
    }
    for(AfterPostCommentHandler handler in handlerList){
      handler.handle(result);
    }
    return comment;
  }

}

abstract class AfterPostCommentHandler{

  void handle(Comment comment);
}
