
import 'package:freego_flutter/http/http_product_question.dart';
import 'package:freego_flutter/http/http_product_question_answer.dart';
import 'package:freego_flutter/model/product_question.dart';

class QuestionUtil{

  static final List<AfterPostQuestionHandler> _afterPostQuestionHandlerList = [];

  static bool addAfterPostQuestionHandler(AfterPostQuestionHandler handler){
    if(_afterPostQuestionHandlerList.contains(handler)){
      return false;
    }
    _afterPostQuestionHandlerList.add(handler);
    return true;
  }

  static bool removeAfterPostQuestionHandler(AfterPostQuestionHandler handler){
    return _afterPostQuestionHandlerList.remove(handler);
  }

  static Future<bool> postProductQuestion(ProductQuestion question) async{
    bool result = await HttpProductQuestion.createQuestion(question);
    if(result){
      for(AfterPostQuestionHandler handler in _afterPostQuestionHandlerList){
        handler.handle(question);
      }
    }
    return result;
  }
}

abstract class AfterPostQuestionHandler{

  void handle(ProductQuestion question);
}

class QuestionAnswerUtil{
  
  static final List<AfterPostQuestionAnswerHandler> _afterPostQuestionAnswerHandlerList = [];

  static bool addAfterPostQuestionAnswerHandler(AfterPostQuestionAnswerHandler handler){
    if(_afterPostQuestionAnswerHandlerList.contains(handler)){
      return false;
    }
    _afterPostQuestionAnswerHandlerList.add(handler);
    return true;
  }

  static bool removeAfterPostQuestionAnswerHandler(AfterPostQuestionAnswerHandler handler){
    return _afterPostQuestionAnswerHandlerList.remove(handler);
  }

  static Future<bool> postProductQuestionAnswer(ProductQuestionAnswer answer) async{
    bool result = await HttpProductQuestionAnswer.createAnswer(answer);
    if(result){
      for(AfterPostQuestionAnswerHandler handler in _afterPostQuestionAnswerHandlerList){
        handler.handle(answer);
      }
    }
    return result;
  }
}

abstract class AfterPostQuestionAnswerHandler{

  void handle(ProductQuestionAnswer answer);
}
