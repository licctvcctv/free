
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/components/comment/comment_sub_http.dart';

class CommentSubUtil{

  CommentSubUtil._internal();
  static final CommentSubUtil _instance = CommentSubUtil._internal();
  factory CommentSubUtil(){
    return _instance;
  }

  List<AfterPostCommentSubHandler> handlerList = [];

  bool addHandler(AfterPostCommentSubHandler handler){
    if(handlerList.contains(handler)){
      return false;
    }
    handlerList.add(handler);
    return true;
  }
  bool removeHandler(AfterPostCommentSubHandler handler){
    return handlerList.remove(handler);
  }

  Future<CommentSub?> post(CommentSub commentSub) async{
    CommentSub? result = await CommentSubHttp().post(commentSub);
    if(result == null){
      return null;
    }
    for(AfterPostCommentSubHandler handler in handlerList){
      handler.handler(result);
    }
    return result;
  }
}

abstract class AfterPostCommentSubHandler{

  void handler(CommentSub commentSub);
}
